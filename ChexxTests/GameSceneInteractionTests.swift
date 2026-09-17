import XCTest
import SpriteKit
@testable import Chexx

// Exercises GameScene's touchDown/touchUp interaction handlers with a live SKView-presented
// scene, the same way both iOS touches (touchesBegan/touchesEnded) and native macOS mouse
// events (mouseDown/mouseUp) route into them — see GameScene.touchesBegan/touchesEnded and
// GameScene.mouseDown/mouseUp, which both just forward to touchDown(atPoint:)/touchUp(atPoint:).
// Confirms tile selection, piece movement, and turn advancement work end-to-end through that
// shared interaction code path, standing in for manually playing a game on the native macOS
// destination (not otherwise verifiable in this environment without a live, unlocked screen).
final class GameSceneInteractionTests: XCTestCase {
    override func setUp() async throws {
        try await super.setUp()
        // Pass & Play persists to "currentPassAndPlay" on every move; start from a clean slate
        // so a stray save from prior manual testing on this host app doesn't change the board
        // layout this test relies on.
        //
        // The flush is what makes this reliable between tests: saves are written off the main
        // thread, so without draining the queue first, a save from the previous test could land
        // after this delete and hand the next scene a half-played board.
        await GameFileStore.shared.flush()
        deleteGameFile(filename: "currentPassAndPlay")
    }

    override func tearDown() async throws {
        await GameFileStore.shared.flush()
        deleteGameFile(filename: "currentPassAndPlay")
        try await super.tearDown()
    }

    private func makeLoadedScene() -> GameScene {
        let scene = GameScene(size: CGSize(width: 900, height: 900), isVsCPU: false, isPassAndPlay: true, isOnlineMultiplayer: false)
        let view = SKView(frame: CGRect(x: 0, y: 0, width: 900, height: 900))
        view.presentScene(scene)
        return scene
    }

    func testSelectingAndMovingAPawnAdvancesTheTurn() {
        let scene = makeLoadedScene()
        XCTAssertEqual(scene.gameState.currentPlayer, "white")

        guard let fromHexagon = scene.hexagonsByName["f5"], let toHexagon = scene.hexagonsByName["f6"] else {
            return XCTFail("expected f5/f6 hexagons to exist on a freshly-generated board")
        }

        scene.touchDown(atPoint: fromHexagon.position)
        XCTAssertNotNil(scene.selectedPiece, "tapping a piece belonging to the current player should select it")
        XCTAssertTrue(scene.validMoves.contains("f6"), "f5's pawn should be able to advance to f6")

        scene.touchUp(atPoint: toHexagon.position)

        XCTAssertNil(scene.selectedPiece, "the piece should be deselected once the move completes")
        XCTAssertEqual(scene.gameState.currentPlayer, "black", "making a move should advance the turn")
        XCTAssertEqual(scene.gameState[5, 5]?.color, "white", "f6 (col 5, row 5) should now hold the moved pawn")
        XCTAssertEqual(scene.gameState[5, 5]?.type, "pawn")
        XCTAssertNil(scene.gameState[5, 4], "f5 should be empty after the pawn moved away")
    }

    func testTappingFarOutsideTheBoardDeselectsWithoutMoving() {
        let scene = makeLoadedScene()

        guard let fromHexagon = scene.hexagonsByName["f5"] else {
            return XCTFail("expected an f5 hexagon to exist on a freshly-generated board")
        }

        scene.touchDown(atPoint: fromHexagon.position)
        XCTAssertNotNil(scene.selectedPiece)

        scene.touchDown(atPoint: CGPoint(x: 10_000, y: 10_000))

        XCTAssertNil(scene.selectedPiece, "tapping far outside the board should deselect the current piece")
        XCTAssertEqual(scene.gameState.currentPlayer, "white", "no move was made, so it should still be white's turn")
    }
}
