import XCTest
@testable import Chexx

/// Placeholder sanity test confirming the ChexxTests target builds, links against
/// the Chexx app target via @testable import, and can exercise basic game state.
/// Real CPU correctness/perft/benchmark suites are added in follow-up subtasks.
final class ChexxTests: XCTestCase {
    func testInitialGameStateHasPiecesForBothSides() {
        let state = GameState()
        let whitePieces = state.board.compactMap { $0 }.filter { $0.color == "white" }
        let blackPieces = state.board.compactMap { $0 }.filter { $0.color == "black" }

        XCTAssertFalse(whitePieces.isEmpty)
        XCTAssertFalse(blackPieces.isEmpty)
        XCTAssertEqual(whitePieces.count, blackPieces.count)
    }
}
