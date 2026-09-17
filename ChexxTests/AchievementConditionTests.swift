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
}
