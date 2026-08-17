import XCTest
@testable import Chexx

/// Covers the offline-trained piece-square-table evaluator (LearnedEvalWeights) and the
/// GameCPU.useLearnedEvaluation feature flag that gates it, added in the "Add AI components to
/// CPU?" section of TO DO.md.
final class LearnedEvalWeightsTests: XCTestCase {
    func testWeightTableHasAllPieceTypesForBothColorsWithOneWeightPerSquare() {
        for color in ["white", "black"] {
            let colorTable = LearnedEvalWeights.weights[color]
            XCTAssertNotNil(colorTable, "Missing weight table for color \(color)")

            for pieceType in ["pawn", "knight", "bishop", "rook", "queen", "king"] {
                let squareWeights = colorTable?[pieceType]
                XCTAssertEqual(squareWeights?.count, GameState.tileCount, "\(color) \(pieceType) should have one weight per board square")
            }
        }
    }

    func testGameCPUDefaultsToMaterialOnlyEvaluation() {
        let cpu = GameCPU(difficulty: .medium)
        XCTAssertFalse(cpu.useLearnedEvaluation)
    }

    func testMinimaxSearchCompletesWithLearnedEvaluationEnabled() {
        var state = GameState()
        let cpu = GameCPU(difficulty: .medium)
        cpu.useLearnedEvaluation = true

        let move = cpu.findMove(gameState: &state)

        XCTAssertNotNil(move, "GameCPU should still return a legal move from the starting position with the learned evaluator enabled")
    }
}
