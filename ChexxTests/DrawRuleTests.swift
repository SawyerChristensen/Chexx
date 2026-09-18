import XCTest
@testable import Chexx

/// Covers the per-game state behind the 50-move and threefold-repetition draw rules. Both read from
/// the same two fields, so they're tested together.
///
/// Note these assert the *bookkeeping*, not the game ending — detecting a draw and presenting it are
/// separate from tracking the state that makes detection possible.
final class DrawRuleTests: XCTestCase {

    // MARK: - Fifty-move clock

    func testQuietMovesAdvanceTheHalfmoveClock() {
        var state = GameState()
        XCTAssertEqual(state.halfmoveClock, 0)

        state.recordPositionAfterMove(wasCapture: false, wasPawnMove: false)
        state.recordPositionAfterMove(wasCapture: false, wasPawnMove: false)

        XCTAssertEqual(state.halfmoveClock, 2)
    }

    func testACaptureResetsTheHalfmoveClock() {
        var state = GameState()
        for _ in 0..<5 { state.recordPositionAfterMove(wasCapture: false, wasPawnMove: false) }
        XCTAssertEqual(state.halfmoveClock, 5)

        state.recordPositionAfterMove(wasCapture: true, wasPawnMove: false)

        XCTAssertEqual(state.halfmoveClock, 0)
    }

    func testAPawnMoveResetsTheHalfmoveClock() {
        var state = GameState()
        for _ in 0..<5 { state.recordPositionAfterMove(wasCapture: false, wasPawnMove: false) }

        state.recordPositionAfterMove(wasCapture: false, wasPawnMove: true)

        XCTAssertEqual(state.halfmoveClock, 0)
    }

    // The rule is fifty moves by *each* player, so the threshold is 100 plies, not 50. Getting this
    // off by a factor of two would roughly halve every drawn endgame.
    func testFiftyMoveDrawTriggersAtOneHundredPlies() {
        var state = GameState()
        for _ in 0..<99 { state.recordPositionAfterMove(wasCapture: false, wasPawnMove: false) }

        XCTAssertEqual(state.halfmoveClock, 99)
        XCTAssertFalse(state.isFiftyMoveDraw, "99 plies is 49.5 moves each — not yet a draw")

        state.recordPositionAfterMove(wasCapture: false, wasPawnMove: false)

        XCTAssertTrue(state.isFiftyMoveDraw)
    }

    // MARK: - Repetition history

    // The same placement with the other player to move is a different position — a rule that
    // matters, since players alternate and every position would otherwise look repeated twice as
    // often as it is.
    func testRepetitionKeyDependsOnWhoseTurnItIs() {
        var state = GameState()
        let whiteToMove = state.repetitionKey
        state.currentPlayer = "black"

        XCTAssertNotEqual(whiteToMove, state.repetitionKey)
    }

    func testRepeatingAPositionThreeTimesIsDetected() {
        var state = GameState()
        // Same board, same side to move, reached three times by quiet moves.
        state.recordPositionAfterMove(wasCapture: false, wasPawnMove: false)
        XCTAssertEqual(state.currentPositionRepetitionCount(), 1)
        XCTAssertFalse(state.isThreefoldRepetition)

        state.recordPositionAfterMove(wasCapture: false, wasPawnMove: false)
        XCTAssertEqual(state.currentPositionRepetitionCount(), 2)
        XCTAssertFalse(state.isThreefoldRepetition, "two occurrences is not yet threefold")

        state.recordPositionAfterMove(wasCapture: false, wasPawnMove: false)
        XCTAssertTrue(state.isThreefoldRepetition)
    }

    // A capture or pawn move is irreversible, so nothing before it can recur. Keeping the earlier
    // entries would leave stale keys able to trigger a false threefold.
    func testAnIrreversibleMoveClearsTheRepetitionHistory() {
        var state = GameState()
        state.recordPositionAfterMove(wasCapture: false, wasPawnMove: false)
        state.recordPositionAfterMove(wasCapture: false, wasPawnMove: false)
        XCTAssertEqual(state.positionHistory.count, 2)

        state.recordPositionAfterMove(wasCapture: true, wasPawnMove: false)

        XCTAssertEqual(state.positionHistory.count, 1, "only the position after the capture remains")
        XCTAssertEqual(state.currentPositionRepetitionCount(), 1)
        XCTAssertFalse(state.isThreefoldRepetition)
    }

    // MARK: - Persistence

    // Same migration hazard as the achievement counters: GameState has a hand-written init(from:),
    // and a game saved before these fields existed has to keep loading.
    func testGameStateDecodesSavesWrittenBeforeTheDrawFieldsExisted() throws {
        let encoded = try JSONEncoder().encode(GameState())
        var json = try XCTUnwrap(try JSONSerialization.jsonObject(with: encoded) as? [String: Any])
        for key in ["halfmoveClock", "positionHistory"] {
            XCTAssertNotNil(json[key], "\(key) must be persisted — it can't be recomputed from a board")
            json.removeValue(forKey: key)
        }

        let legacy = try JSONSerialization.data(withJSONObject: json)
        let decoded = try JSONDecoder().decode(GameState.self, from: legacy)

        XCTAssertEqual(decoded.halfmoveClock, 0)
        XCTAssertTrue(decoded.positionHistory.isEmpty)
    }

    func testDrawStateSurvivesASaveAndReload() throws {
        var state = GameState()
        for _ in 0..<3 { state.recordPositionAfterMove(wasCapture: false, wasPawnMove: false) }

        let decoded = try JSONDecoder().decode(GameState.self, from: JSONEncoder().encode(state))

        XCTAssertEqual(decoded.halfmoveClock, 3)
        XCTAssertEqual(decoded.positionHistory, state.positionHistory)
    }
}
