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

    // MARK: - Ending the game

    func testFiftyMoveClockEndsTheGameAsADraw() {
        var state = GameState()   // opening position: legal moves available, nobody in check
        state.halfmoveClock = 100

        let result = state.isGameOver()

        XCTAssertTrue(result.0)
        XCTAssertEqual(result.1, "fiftyMoveRule")
    }

    func testThreefoldRepetitionEndsTheGameAsADraw() {
        var state = GameState()
        state.positionHistory = Array(repeating: state.repetitionKey, count: 3)

        let result = state.isGameOver()

        XCTAssertTrue(result.0)
        XCTAssertEqual(result.1, "threefoldRepetition")
    }

    // A position that ends the game outright must win over a draw that happens to be claimable on
    // the same move — otherwise a long endgame would be reported as a draw instead of the stalemate
    // (which this game scores as a win) that actually occurred. This is the ordering inside
    // isGameOver, so it's worth pinning rather than trusting.
    func testAnEndedPositionTakesPrecedenceOverAClaimableDraw() {
        // Same stalemate position as ChexxTests.testCornerStalemate.
        var state = GameState()
        state.board = Array(repeating: nil, count: GameState.tileCount)
        state.whiteSliderCount = 0
        state.blackSliderCount = 0
        state.currentPlayer = "black"
        state.setPiece(Piece(color: "black", type: "king"), at: "a1")
        state.blackKingPosition = "a1"
        state.setPiece(Piece(color: "white", type: "king"), at: "l1")
        state.whiteKingPosition = "l1"
        state.setPiece(Piece(color: "white", type: "rook"), at: "c2")
        state.setPiece(Piece(color: "white", type: "rook"), at: "b5")
        state.setPiece(Piece(color: "white", type: "rook"), at: "c5")
        state.whiteSliderCount = 3

        // Both draws are simultaneously claimable.
        state.halfmoveClock = 150
        state.positionHistory = Array(repeating: state.repetitionKey, count: 5)

        let result = state.isGameOver()

        XCTAssertEqual(result.1, "stalemate", "stalemate must win over a claimable draw")
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
