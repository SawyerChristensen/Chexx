import XCTest
@testable import Chexx

/// Edge-case behavior tests for the CPU-facing move rules: en passant capture, promotion-choice
/// handling, and pinned-piece move filtering. Glinski's hexagonal chess (this app's only variant)
/// has no castling (see TutorialSheet's rules text), so that case is intentionally not covered here.
final class GameRulesEdgeCaseTests: XCTestCase {
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

    // MARK: - En passant

    // White double-steps f4-f6, flagging the pawn as an en passant target. Black's e5 pawn is
    // diagonally adjacent to that target and should be able to capture en passant by moving to f5,
    // removing the f6 pawn even though f5 itself was empty.
    func testEnPassantCaptureRemovesTheDoubleSteppedPawn() {
        var state = emptyGameState(currentPlayer: "white")
        state.setPiece(Piece(color: "white", type: "king"), at: "a1")
        state.whiteKingPosition = "a1"
        state.setPiece(Piece(color: "black", type: "king"), at: "l1")
        state.blackKingPosition = "l1"
        state.setPiece(Piece(color: "white", type: "pawn"), at: "f4") // (5,3)
        state.setPiece(Piece(color: "black", type: "pawn", hasMoved: true), at: "e5") // (4,4)

        _ = state.makeMove(fromCol: 5, fromRow: 3, toCol: 5, toRow: 5) // f4-f6 double step
        XCTAssertEqual(state[5, 5]?.isEnPassantTarget, true)

        let blackMoves = Set(validMovesForPawn("black", at: (4, 4), in: state).map { "\($0.0),\($0.1)" })
        XCTAssertTrue(blackMoves.contains("5,4"), "black e5 pawn should be able to capture en passant onto f5")

        _ = state.makeMove(fromCol: 4, fromRow: 4, toCol: 5, toRow: 4) // e5xf5 en passant

        XCTAssertNil(state[5, 5], "the double-stepped white pawn should be removed by the en passant capture")
        XCTAssertEqual(state[5, 4]?.color, "black")
        XCTAssertEqual(state[5, 4]?.type, "pawn")
    }

    // A single-step pawn move never sets the en passant flag, so a pawn that could otherwise be
    // captured en passant one tile over must NOT offer that capture.
    func testNoEnPassantCaptureAvailableAfterSingleStep() {
        var state = emptyGameState(currentPlayer: "white")
        state.setPiece(Piece(color: "white", type: "king"), at: "a1")
        state.whiteKingPosition = "a1"
        state.setPiece(Piece(color: "black", type: "king"), at: "l1")
        state.blackKingPosition = "l1"
        state.setPiece(Piece(color: "white", type: "pawn"), at: "f5") // (5,4)
        state.setPiece(Piece(color: "black", type: "pawn", hasMoved: true), at: "e5") // (4,4)

        _ = state.makeMove(fromCol: 5, fromRow: 4, toCol: 5, toRow: 5) // f5-f6 single step
        XCTAssertEqual(state[5, 5]?.isEnPassantTarget, false)

        let blackMoves = Set(validMovesForPawn("black", at: (4, 4), in: state).map { "\($0.0),\($0.1)" })
        XCTAssertFalse(blackMoves.contains("5,4"), "no en passant capture should exist after a single-step pawn move")
    }

    // MARK: - Promotion choices

    // makeMove's promotionType parameter should be honored exactly, so the CPU's choice of
    // underpromotion (e.g. to a knight) actually lands rather than always becoming a queen.
    func testPawnPromotionRespectsRequestedPieceType() {
        var state = emptyGameState(currentPlayer: "white")
        state.setPiece(Piece(color: "white", type: "king"), at: "a1")
        state.whiteKingPosition = "a1"
        state.setPiece(Piece(color: "black", type: "king"), at: "l1")
        state.blackKingPosition = "l1"
        state.setPiece(Piece(color: "white", type: "pawn", hasMoved: true), at: "f10") // (5,9)

        _ = state.makeMove(fromCol: 5, fromRow: 9, toCol: 5, toRow: 10, promotionType: "knight")

        XCTAssertEqual(state[5, 10]?.type, "knight")
        XCTAssertEqual(state[5, 10]?.color, "white")
    }

    // Omitting promotionType should still default to queen, matching makeMove's default parameter.
    func testPawnPromotionDefaultsToQueenWhenUnspecified() {
        var state = emptyGameState(currentPlayer: "white")
        state.setPiece(Piece(color: "white", type: "king"), at: "a1")
        state.whiteKingPosition = "a1"
        state.setPiece(Piece(color: "black", type: "king"), at: "l1")
        state.blackKingPosition = "l1"
        state.setPiece(Piece(color: "white", type: "pawn", hasMoved: true), at: "f10") // (5,9)

        _ = state.makeMove(fromCol: 5, fromRow: 9, toCol: 5, toRow: 10)

        XCTAssertEqual(state[5, 10]?.type, "queen")
    }

    // Regression guard for the "gameCPU will not see knight's moves upon promotion, only queen"
    // bug: once a pawn underpromotes to a knight, its legal moves must follow knight movement
    // (short jumps), not carry over queen-style sliding moves.
    func testPromotedKnightMovesLikeAKnightNotAQueen() {
        var state = emptyGameState(currentPlayer: "white")
        state.setPiece(Piece(color: "white", type: "king"), at: "a1")
        state.whiteKingPosition = "a1"
        state.setPiece(Piece(color: "black", type: "king"), at: "l1")
        state.blackKingPosition = "l1"
        state.setPiece(Piece(color: "white", type: "pawn", hasMoved: true), at: "f10") // (5,9)

        _ = state.makeMove(fromCol: 5, fromRow: 9, toCol: 5, toRow: 10, promotionType: "knight")

        let expectedKnightMoves = Set(validMovesForKnight("white", at: (5, 10), in: state).map { "\($0.0),\($0.1)" })
        let actualMoves = Set(validMovesForPiece(at: (5, 10), color: "white", type: "knight", in: &state).map { "\($0.0),\($0.1)" })

        XCTAssertFalse(expectedKnightMoves.isEmpty)
        XCTAssertEqual(actualMoves, expectedKnightMoves)
    }

    // MARK: - Pinned-piece move filtering

    // A white knight at a3, directly between the white king at a1 and a black rook at a5 on the
    // same file, is pinned: removing it would expose the king to the rook's ray. Since a knight
    // can't move without leaving that file, every one of its pseudo-legal moves must be filtered out.
    func testPinnedKnightHasNoLegalMoves() {
        var state = emptyGameState(currentPlayer: "white")
        state.setPiece(Piece(color: "white", type: "king"), at: "a1")
        state.whiteKingPosition = "a1"
        state.setPiece(Piece(color: "black", type: "king"), at: "l1")
        state.blackKingPosition = "l1"
        state.setPiece(Piece(color: "white", type: "knight"), at: "a3") // (0,2)
        state.setPiece(Piece(color: "black", type: "rook"), at: "a5") // (0,4)
        state.blackSliderCount = 1

        let pseudoLegalMoves = validMovesForKnight("white", at: (0, 2), in: state)
        XCTAssertFalse(pseudoLegalMoves.isEmpty, "sanity check: the knight should have pseudo-legal moves before pin filtering")

        let legalMoves = validMovesForPiece(at: (0, 2), color: "white", type: "knight", in: &state)
        XCTAssertTrue(legalMoves.isEmpty, "a pinned knight has no legal moves since it can't stay on the pin line")
    }

    // A white rook pinned along its own file (same setup as above, but the pinned piece is itself
    // a rook) can still legally move as long as it stays on the pin line, including capturing the
    // pinning rook outright, since none of those moves expose the king.
    func testPinnedRookCanStillMoveAlongThePinLine() {
        var state = emptyGameState(currentPlayer: "white")
        state.setPiece(Piece(color: "white", type: "king"), at: "a1")
        state.whiteKingPosition = "a1"
        state.setPiece(Piece(color: "black", type: "king"), at: "l1")
        state.blackKingPosition = "l1"
        state.setPiece(Piece(color: "white", type: "rook"), at: "a3") // (0,2)
        state.setPiece(Piece(color: "black", type: "rook"), at: "a5") // (0,4)
        state.whiteSliderCount = 1
        state.blackSliderCount = 1

        let legalMoves = Set(validMovesForPiece(at: (0, 2), color: "white", type: "rook", in: &state).map { "\($0.0),\($0.1)" })

        // a2 (staying between king and pin), a4 (still blocking), a5 (capturing the pinning rook)
        XCTAssertEqual(legalMoves, ["0,1", "0,3", "0,4"])
    }

    // MARK: - Opening book

    // GameCPU short-circuits its very first move (Black's reply to White's first move) with a
    // hardcoded mirrored pawn push instead of running a search, whenever White's opening move was
    // itself a single or double pawn push. See GameCPU.openingBookMove.
    func testOpeningBookMirrorsASingleStepPawnPush() {
        var state = GameState()
        _ = state.makeMove(fromCol: 9, fromRow: 0, toCol: 9, toRow: 1) // k1-k2
        state.addMoveToHexPgn(from: "k1", to: "k2", promotionOffset: 0)
        state.currentPlayer = "black"
        XCTAssertEqual(state.HexPgn.count, 3, "sanity check: exactly White's first move has been recorded")

        let cpu = GameCPU(difficulty: .extraHard)
        let move = cpu.findMove(gameState: &state)
        XCTAssertEqual(move?.start, "k7")
        XCTAssertEqual(move?.destination, "k6")
    }

    func testOpeningBookMirrorsADoubleStepPawnPush() {
        var state = GameState()
        _ = state.makeMove(fromCol: 9, fromRow: 0, toCol: 9, toRow: 2) // k1-k3
        state.addMoveToHexPgn(from: "k1", to: "k3", promotionOffset: 0)
        state.currentPlayer = "black"
        XCTAssertEqual(state.HexPgn.count, 3, "sanity check: exactly White's first move has been recorded")

        let cpu = GameCPU(difficulty: .extraHard)
        let move = cpu.findMove(gameState: &state)
        XCTAssertEqual(move?.start, "k7")
        XCTAssertEqual(move?.destination, "k5")
    }
}
