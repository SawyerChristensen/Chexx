import XCTest
@testable import Chexx

/// Plays out full CPU-vs-CPU games so their recorded HexPgn move histories and results can later
/// be turned into training data for a learned evaluation function (see "Add AI components to CPU?"
/// in TO DO.md). This harness only plays games and records outcomes — extracting per-position
/// training records from the recorded games is a separate, follow-on step.
enum SelfPlayGenerator {
    struct GameRecord {
        let hexPgn: [UInt8]
        let result: String // "white", "black" (checkmate winner), "stalemate", or "incomplete"
        let plyCount: Int
    }

    /// Plays `count` full games with both sides controlled by a CPU of the given difficulty,
    /// stopping each game at checkmate/stalemate or after `maxPlies` half-moves — a safety cap,
    /// since threefold-repetition detection isn't implemented yet and a position could otherwise
    /// loop forever.
    static func playGames(count: Int, difficulty: CPUDifficulty = .extraHard, maxPlies: Int = 300) -> [GameRecord] {
        (0..<count).map { _ in playSingleGame(difficulty: difficulty, maxPlies: maxPlies) }
    }

    private static func playSingleGame(difficulty: CPUDifficulty, maxPlies: Int) -> GameRecord {
        var gameState = GameState()
        let cpu = GameCPU(difficulty: difficulty)
        var plies = 0

        while plies < maxPlies {
            let (isOver, status) = gameState.isGameOver()
            if isOver {
                let result = status == "checkmate" ? (gameState.currentPlayer == "white" ? "black" : "white") : "stalemate"
                return GameRecord(hexPgn: gameState.HexPgn, result: result, plyCount: plies)
            }

            guard let move = cpu.findMove(gameState: &gameState) else { break }

            _ = gameState.makeMove(move.start, to: move.destination, promotionType: move.promotion ?? "queen")
            gameState.addMoveToHexPgn(from: move.start, to: move.destination, promotionOffset: promotionOffset(for: move.promotion))

            let opponentColor = gameState.currentPlayer == "white" ? "black" : "white"
            gameState.currentPlayer = opponentColor
            resetEnPassant(for: opponentColor, in: &gameState)
            plies += 1
        }

        return GameRecord(hexPgn: gameState.HexPgn, result: "incomplete", plyCount: plies)
    }

    private static func promotionOffset(for promotion: String?) -> UInt8 {
        switch promotion {
        case "queen": return 91
        case "rook": return 92
        case "bishop": return 93
        case "knight": return 94
        default: return 0
        }
    }

    // Mirrors GameScene.resetEnPassant: clears the en passant target flag once the window during
    // which it could've been captured (the mover's opponent's very next move) has passed.
    private static func resetEnPassant(for color: String, in gameState: inout GameState) {
        guard let col = gameState.enPassantCol, let row = gameState.enPassantRow,
              gameState[col, row]?.color == color else { return }
        gameState[col, row]?.isEnPassantTarget = false
        gameState.enPassantCol = nil
        gameState.enPassantRow = nil
    }
}

/// Sanity check that the self-play harness terminates and produces well-formed game records.
/// Uses `.medium` difficulty and a low ply cap so this stays fast enough to run as part of the
/// normal test suite; generating a real training dataset (high difficulty, many games) is a
/// separate follow-on task.
final class SelfPlayGeneratorTests: XCTestCase {
    func testPlayGamesProducesWellFormedRecords() {
        let records = SelfPlayGenerator.playGames(count: 2, difficulty: .medium, maxPlies: 40)

        XCTAssertEqual(records.count, 2)
        for record in records {
            XCTAssertFalse(record.hexPgn.isEmpty)
            XCTAssertGreaterThanOrEqual(record.plyCount, 0)
            XCTAssertTrue(["white", "black", "stalemate", "incomplete"].contains(record.result))
        }
    }
}
