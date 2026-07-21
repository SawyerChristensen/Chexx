import XCTest
@testable import Chexx

/// CPU correctness tests: hand-verified legal-move-count (perft-style) assertions and known
/// checkmate/stalemate positions, checked against GameState/PieceRules move generation.
/// Benchmark and edge-case (en passant/castling/promotion/pin) suites are added in follow-up subtasks.
final class ChexxTests: XCTestCase {
    func testInitialGameStateHasPiecesForBothSides() {
        let state = GameState()
        let whitePieces = state.board.compactMap { $0 }.filter { $0.color == "white" }
        let blackPieces = state.board.compactMap { $0 }.filter { $0.color == "black" }

        XCTAssertFalse(whitePieces.isEmpty)
        XCTAssertFalse(blackPieces.isEmpty)
        XCTAssertEqual(whitePieces.count, blackPieces.count)
    }

    // Board with no pieces at all and both slider counts zeroed, so tests can place only the
    // pieces a given position needs without stale counts/material from GameState()'s default setup.
    private func emptyGameState(currentPlayer: String) -> GameState {
        var state = GameState()
        state.board = Array(repeating: nil, count: GameState.tileCount)
        state.whiteSliderCount = 0
        state.blackSliderCount = 0
        state.currentPlayer = currentPlayer
        return state
    }

    // A king on an open board (f6, the exact center hex) has all 12 of Glinski's king-move
    // directions available, since none of the 12 destination hexes fall off the board.
    func testKingInOpenCenterHasTwelveMoves() {
        var state = emptyGameState(currentPlayer: "white")
        state.setPiece(Piece(color: "white", type: "king"), at: "f6")
        state.whiteKingPosition = "f6"

        let moves = Set(validMovesForPiece(at: "f6", color: "white", type: "king", in: &state))
        let expected: Set<String> = ["f7", "f5", "d5", "h5", "e6", "g6", "e5", "g5", "e7", "g7", "e4", "g4"]

        XCTAssertEqual(moves, expected)
    }

    // A king in the a1 corner only has 5 of the 12 directions land on the board: a2, b1, b2, b3, c2.
    func testKingInCornerHasFiveMoves() {
        var state = emptyGameState(currentPlayer: "white")
        state.setPiece(Piece(color: "white", type: "king"), at: "a1")
        state.whiteKingPosition = "a1"

        let moves = Set(validMovesForPiece(at: "a1", color: "white", type: "king", in: &state))
        let expected: Set<String> = ["a2", "b1", "b2", "b3", "c2"]

        XCTAssertEqual(moves, expected)
    }

    // Corner checkmate: a black king cornered at a1 has exactly 5 destination hexes (a2, b1, b2,
    // b3, c2). A white rook at b2 checks a1 directly (adjacent, so uncapturable/unblockable except
    // by capture) and its rook rays alone also cover a2, b1, b3, and c2. A second white rook at b5
    // defends b2 along the same file, so capturing the checking rook still leaves the king in check.
    func testCornerCheckmateWithTwoRooks() {
        var state = emptyGameState(currentPlayer: "black")
        state.setPiece(Piece(color: "black", type: "king"), at: "a1")
        state.blackKingPosition = "a1"
        state.setPiece(Piece(color: "white", type: "king"), at: "l1")
        state.whiteKingPosition = "l1"
        state.setPiece(Piece(color: "white", type: "rook"), at: "b2")
        state.setPiece(Piece(color: "white", type: "rook"), at: "b5")
        state.whiteSliderCount = 2

        let result = state.isGameOver()

        XCTAssertTrue(result.0)
        XCTAssertEqual(result.1, "checkmate")
    }

    // Same checking rook as the checkmate above, but undefended: the black king can escape check
    // by capturing it, so the position is check, not checkmate.
    func testCornerCheckIsNotCheckmateWhenRookUndefended() {
        var state = emptyGameState(currentPlayer: "black")
        state.setPiece(Piece(color: "black", type: "king"), at: "a1")
        state.blackKingPosition = "a1"
        state.setPiece(Piece(color: "white", type: "king"), at: "l1")
        state.whiteKingPosition = "l1"
        state.setPiece(Piece(color: "white", type: "rook"), at: "b2")
        state.whiteSliderCount = 1

        let result = state.isGameOver()

        XCTAssertFalse(result.0)
        XCTAssertTrue(result.1.hasPrefix("check by"))
    }

    // Corner stalemate: a black king at a1 is NOT in check, but all 5 of its destination hexes are
    // unavailable. A white rook at c2 covers a2 and b1 (up-left/down-left rays) without its rays
    // ever crossing a1, and is itself defended by a rook at c5. A rook at b5 covers b2 and b3 along
    // its file. None of the three white rooks has a1 on any of its rays, so the king is stalemated
    // rather than checkmated.
    func testCornerStalemate() {
        var state = emptyGameState(currentPlayer: "black")
        state.setPiece(Piece(color: "black", type: "king"), at: "a1")
        state.blackKingPosition = "a1"
        state.setPiece(Piece(color: "white", type: "king"), at: "l1")
        state.whiteKingPosition = "l1"
        state.setPiece(Piece(color: "white", type: "rook"), at: "c2")
        state.setPiece(Piece(color: "white", type: "rook"), at: "b5")
        state.setPiece(Piece(color: "white", type: "rook"), at: "c5")
        state.whiteSliderCount = 3

        let result = state.isGameOver()

        XCTAssertTrue(result.0)
        XCTAssertEqual(result.1, "stalemate")
    }
}
