import XCTest
@testable import Chexx

/// Covers the board-derived conditions behind the Group A achievements (Tactical Hexcellence,
/// Hexclusion Zone). The unlock calls themselves live inside GameScene's game-over handler and
/// aren't reachable from a unit test, so what's pinned here is the logic those calls rely on:
/// the starting-piece-count constant, and the two facts that make the smothered-mate test valid.
final class AchievementConditionTests: XCTestCase {

    // Same empty-board helper the other suites use: no pieces, zeroed slider counts, so a test
    // places only what its position needs.
    private func emptyGameState(currentPlayer: String) -> GameState {
        var state = GameState()
        state.board = Array(repeating: nil, count: GameState.tileCount)
        state.whiteSliderCount = 0
        state.blackSliderCount = 0
        state.currentPlayer = currentPlayer
        return state
    }

    // MARK: - Tactical Hexcellence

    // startingPieceCountPerSide is hand-maintained next to setInitialPiecePositions, and Tactical
    // Hexcellence ("checkmate without losing any pieces") compares the winner's surviving piece
    // count against it. If someone edits the opening setup without updating the constant, the
    // achievement silently stops being winnable — this test is what catches that.
    func testStartingPieceCountConstantMatchesTheInitialBoard() {
        let state = GameState()
        let white = state.getPieces(for: "white").count
        let black = state.getPieces(for: "black").count

        XCTAssertEqual(white, GameState.startingPieceCountPerSide)
        XCTAssertEqual(black, GameState.startingPieceCountPerSide)
    }

    // MARK: - Hexclusion Zone (smothered mate)

    // The smothered-mate test is `loserKingWouldBeValidMoves.isEmpty`, which is only a valid
    // stand-in for "every neighbour is a friendly piece" because king move generation drops
    // own-colour squares. Pin that: a king boxed in by its own pieces has nowhere to go.
    func testKingSurroundedByFriendlyPiecesHasNoPseudoLegalMoves() {
        var state = emptyGameState(currentPlayer: "white")
        state.setPiece(Piece(color: "white", type: "king"), at: "a1")
        state.whiteKingPosition = "a1"
        // a1's five on-board neighbours, per testKingInCornerHasFiveMoves.
        for square in ["a2", "b1", "b2", "b3", "c2"] {
            state.setPiece(Piece(color: "white", type: "pawn"), at: square)
        }

        let moves = validMovesForPiece(at: "a1", color: "white", type: "king", in: &state, skipKingCheck: true)

        XCTAssertTrue(moves.isEmpty, "a king walled in by its own pieces should have no destinations")
    }

    // The other half of that assumption: an *enemy* piece on a neighbouring tile is capturable, so
    // it still counts as a destination. This is what keeps the achievement from firing on a king
    // that's merely surrounded — it has to be surrounded by its *own* pieces.
    func testKingWithAnAdjacentEnemyPieceStillHasAMove() {
        var state = emptyGameState(currentPlayer: "white")
        state.setPiece(Piece(color: "white", type: "king"), at: "a1")
        state.whiteKingPosition = "a1"
        for square in ["a2", "b1", "b2", "b3"] {
            state.setPiece(Piece(color: "white", type: "pawn"), at: square)
        }
        state.setPiece(Piece(color: "black", type: "pawn"), at: "c2")

        let moves = validMovesForPiece(at: "a1", color: "white", type: "king", in: &state, skipKingCheck: true)

        XCTAssertEqual(moves, ["c2"], "the one enemy-held neighbour should remain available as a capture")
    }

    // checkingPiece(against:in:) is the new hook Hexclusion Zone uses to require that the mate was
    // delivered by a knight. Placing the knight on a square it could itself move to from the king's
    // tile keeps this independent of Glinski's knight geometry.
    func testCheckingPieceIdentifiesTheKnightGivingCheck() {
        var state = emptyGameState(currentPlayer: "white")
        state.setPiece(Piece(color: "white", type: "king"), at: "f6")
        state.whiteKingPosition = "f6"

        let knightAttackSquares = validMovesForPiece(at: "f6", color: "white", type: "knight", in: &state)
        let attackSquare = try! XCTUnwrap(knightAttackSquares.first)
        state.setPiece(Piece(color: "black", type: "knight"), at: attackSquare)

        let checker = checkingPiece(against: "white", in: state)

        XCTAssertEqual(checker?.type, "knight")
        XCTAssertEqual(checker?.color, "black")
    }

    // A queen check must not satisfy the knight requirement — otherwise any mate with the king
    // boxed in by its own pieces would count as smothered.
    func testCheckingPieceReportsANonKnightCheckerAsItself() {
        var state = emptyGameState(currentPlayer: "white")
        state.setPiece(Piece(color: "white", type: "king"), at: "f6")
        state.whiteKingPosition = "f6"
        state.setPiece(Piece(color: "black", type: "queen"), at: "f7")
        state.blackSliderCount = 1

        let checker = checkingPiece(against: "white", in: state)

        XCTAssertEqual(checker?.type, "queen")
        XCTAssertNotEqual(checker?.type, "knight")
    }

    func testCheckingPieceIsNilWhenTheKingIsNotInCheck() {
        var state = emptyGameState(currentPlayer: "white")
        state.setPiece(Piece(color: "white", type: "king"), at: "f6")
        state.whiteKingPosition = "f6"
        state.setPiece(Piece(color: "black", type: "king"), at: "a1")
        state.blackKingPosition = "a1"

        XCTAssertNil(checkingPiece(against: "white", in: state))
    }

    // MARK: - Group B per-game counters

    // The migration hazard: GameState has a hand-written init(from:), and these counters were added
    // after games were already being saved to disk. A save written before they existed must still
    // load, with the counters defaulting rather than throwing.
    func testGameStateDecodesSavesWrittenBeforeTheAchievementCountersExisted() throws {
        let encoded = try JSONEncoder().encode(GameState())
        var json = try XCTUnwrap(
            try JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        for key in ["whitePromotionCount", "blackPromotionCount", "whiteTimesPutInCheck",
                    "blackTimesPutInCheck", "visitedTileIndices"] {
            XCTAssertNotNil(json[key], "\(key) should be persisted, otherwise it can't survive a reload")
            json.removeValue(forKey: key)
        }

        let legacy = try JSONSerialization.data(withJSONObject: json)
        let decoded = try JSONDecoder().decode(GameState.self, from: legacy)

        XCTAssertEqual(decoded.whitePromotionCount, 0)
        XCTAssertEqual(decoded.blackPromotionCount, 0)
        XCTAssertEqual(decoded.whiteTimesPutInCheck, 0)
        XCTAssertEqual(decoded.blackTimesPutInCheck, 0)
        XCTAssertTrue(decoded.visitedTileIndices.isEmpty)
    }

    // The counters are the one bit of per-game state that can't be recomputed from the board, so
    // unlike material/zobrist they genuinely have to round-trip.
    func testAchievementCountersSurviveASaveAndReload() throws {
        var state = GameState()
        state.recordPromotion(for: "white")
        state.recordPromotion(for: "white")
        state.recordPutInCheck("black")
        state.visitedTileIndices.insert(GameState.boardIndex(col: 3, row: 2))

        let decoded = try JSONDecoder().decode(GameState.self, from: JSONEncoder().encode(state))

        XCTAssertEqual(decoded.whitePromotionCount, 2)
        XCTAssertEqual(decoded.blackPromotionCount, 0)
        XCTAssertEqual(decoded.blackTimesPutInCheck, 1)
        XCTAssertEqual(decoded.whiteTimesPutInCheck, 0)
        XCTAssertEqual(decoded.visitedTileIndices, [GameState.boardIndex(col: 3, row: 2)])
    }

    func testPerColourCountersDoNotLeakIntoEachOther() {
        var state = GameState()
        state.recordPromotion(for: "black")
        state.recordPutInCheck("white")

        XCTAssertEqual(state.promotionCount(for: "black"), 1)
        XCTAssertEqual(state.promotionCount(for: "white"), 0)
        XCTAssertEqual(state.timesPutInCheck("white"), 1)
        XCTAssertEqual(state.timesPutInCheck("black"), 0)
    }

    // turnCount backs Hexhausted and is derived from HexPgn's layout (one variant byte, then two
    // bytes per move) rather than a stored counter — so it's worth pinning that arithmetic.
    func testTurnCountDerivesFromTheHexPgnMoveList() {
        var state = GameState()
        XCTAssertEqual(state.turnCount, 0, "a fresh game has only the variant byte")

        state.HexPgn.append(contentsOf: [10, 20])
        XCTAssertEqual(state.turnCount, 1)

        state.HexPgn.append(contentsOf: [30, 40])
        XCTAssertEqual(state.turnCount, 2)
    }

    // Hexplorer compares visited tiles against the full board, so the two must agree on size.
    func testVisitingEveryTileMatchesTheBoardSize() {
        var state = GameState()
        for index in 0..<GameState.tileCount {
            state.visitedTileIndices.insert(index)
        }

        XCTAssertEqual(state.visitedTileIndices.count, GameState.tileCount)
        XCTAssertEqual(GameState.tileCount, 91, "Glinski's board is 91 hexes")
    }
}
