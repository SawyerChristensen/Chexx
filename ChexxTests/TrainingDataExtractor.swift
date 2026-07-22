import XCTest
@testable import Chexx

/// Turns recorded `SelfPlayGenerator.GameRecord`s into per-position training records (board state,
/// side to move, outcome) and serializes them as JSON Lines — one JSON object per line — so they
/// can later be used to train a learned evaluation function (see "Add AI components to CPU?" in
/// TO DO.md). Generating a real training dataset at scale is a separate, follow-on step.
enum TrainingDataExtractor {
    struct TrainingRecord: Codable {
        /// Flat 91-entry board snapshot indexed via `GameState.boardIndex(col:row:)`. Each entry is
        /// `""` for an empty tile or `"<color>_<type>"` (e.g. `"white_pawn"`) for an occupied one.
        let board: [String]
        /// Whose turn it is to move in this position: "white" or "black".
        let sideToMove: String
        /// Game outcome from White's perspective: 1.0 white win, 0.0 black win, and — mirroring
        /// this app's own stalemate scoring (see MultiplayerManager/GameScene's Elo adjustment) —
        /// 0.75/0.25 for the side that delivered/received a stalemate.
        let value: Double
        /// Number of half-moves already played to reach this position.
        let ply: Int
    }

    /// Replays every recorded game move-by-move and emits one `TrainingRecord` per position reached
    /// (after each ply), labeled with that game's final outcome. Games that hit the ply cap without
    /// a decisive result ("incomplete") are skipped since there's no reliable outcome to label their
    /// positions with.
    static func extractRecords(from games: [SelfPlayGenerator.GameRecord]) -> [TrainingRecord] {
        var records: [TrainingRecord] = []
        for game in games {
            guard let whiteValue = outcomeValueForWhite(result: game.result, finalPlyCount: game.plyCount) else { continue }
            records.append(contentsOf: positionRecords(hexPgn: game.hexPgn, whiteValue: whiteValue))
        }
        return records
    }

    private static func outcomeValueForWhite(result: String, finalPlyCount: Int) -> Double? {
        switch result {
        case "white": return 1.0
        case "black": return 0.0
        case "stalemate":
            // The stalemated side is whoever was to move when the game ended, which the parity of
            // the final ply count tells us directly (white moves first, so an even count means
            // white is to move next).
            let stalematedColorIsWhite = finalPlyCount % 2 == 0
            return stalematedColorIsWhite ? 0.25 : 0.75
        default: // "incomplete"
            return nil
        }
    }

    // Mirrors GameState.HexPgnToGameState's move-decoding loop, but snapshots the board after each
    // ply instead of only returning the final position.
    private static func positionRecords(hexPgn: [UInt8], whiteValue: Double) -> [TrainingRecord] {
        guard hexPgn.count >= 1 else { return [] }
        var gameState = GameState()
        var records: [TrainingRecord] = []

        for i in stride(from: 1, to: hexPgn.count, by: 2) {
            let fromIndex = hexPgn[i]
            let toIndex = hexPgn[i + 1]
            let plyIndex = (i - 1) / 2

            gameState.currentPlayer = plyIndex % 2 == 0 ? "white" : "black"

            var adjustedIndex: UInt8 = 0
            var promotionPiece: Piece?
            if toIndex >= 91 {
                promotionPiece = gameState.currentPlayer == "white"
                    ? gameState.getPromotionPiece(for: toIndex + 1)
                    : gameState.getPromotionPiece(for: toIndex)

                switch promotionPiece?.type {
                case "queen": adjustedIndex = 91
                case "rook": adjustedIndex = 92
                case "bishop": adjustedIndex = 93
                case "knight": adjustedIndex = 94
                default: adjustedIndex = 0
                }
            }

            let fromPosition = gameState.positionIntToString(index: fromIndex)
            let toPosition = gameState.positionIntToString(index: toIndex - adjustedIndex)
            gameState.movePiece(from: fromPosition, to: toPosition, promotionPiece: promotionPiece)

            let ply = plyIndex + 1
            let sideToMove = ply % 2 == 0 ? "white" : "black"
            records.append(TrainingRecord(board: boardSnapshot(gameState), sideToMove: sideToMove, value: whiteValue, ply: ply))
        }

        return records
    }

    private static func boardSnapshot(_ gameState: GameState) -> [String] {
        gameState.board.map { piece in
            guard let piece else { return "" }
            return "\(piece.color)_\(piece.type)"
        }
    }

    /// Writes `records` as JSON Lines (one compact JSON object per line, no enclosing array) to `url`.
    static func writeJSONL(_ records: [TrainingRecord], to url: URL) throws {
        let encoder = JSONEncoder()
        var lines: [String] = []
        lines.reserveCapacity(records.count)
        for record in records {
            let data = try encoder.encode(record)
            guard let line = String(data: data, encoding: .utf8) else { continue }
            lines.append(line)
        }
        try lines.joined(separator: "\n").write(to: url, atomically: true, encoding: .utf8)
    }
}

/// Sanity checks that position extraction and JSONL serialization produce well-formed output.
/// Uses `.medium` difficulty and a low ply cap so this stays fast enough for the normal test suite;
/// generating a real training dataset (many games, high difficulty) is a separate follow-on task.
final class TrainingDataExtractorTests: XCTestCase {
    func testExtractRecordsProducesOnePerPlyWithConsistentOutcome() {
        let games = SelfPlayGenerator.playGames(count: 2, difficulty: .medium, maxPlies: 40)
        let records = TrainingDataExtractor.extractRecords(from: games)

        let expectedCount = games.filter { $0.result != "incomplete" }.reduce(0) { $0 + $1.plyCount }
        XCTAssertEqual(records.count, expectedCount)

        for record in records {
            XCTAssertEqual(record.board.count, GameState.tileCount)
            XCTAssertTrue(["white", "black"].contains(record.sideToMove))
            XCTAssertTrue([0.0, 0.25, 0.75, 1.0].contains(record.value))
            XCTAssertGreaterThan(record.ply, 0)
        }
    }

    func testWriteJSONLRoundTrips() throws {
        // Constructed directly rather than via self-play: a real game reaching a decisive
        // (non-"incomplete") result within a small ply budget isn't guaranteed run-to-run, and this
        // test only needs to check writeJSONL's serialization, not extractRecords' game-replay logic
        // (already covered by testExtractRecordsProducesOnePerPlyWithConsistentOutcome).
        let emptyBoard = Array(repeating: "", count: GameState.tileCount)
        let records = [
            TrainingDataExtractor.TrainingRecord(board: emptyBoard, sideToMove: "white", value: 1.0, ply: 1),
            TrainingDataExtractor.TrainingRecord(board: emptyBoard, sideToMove: "black", value: 0.25, ply: 2),
        ]

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("chexx-selfplay-\(UUID().uuidString).jsonl")
        defer { try? FileManager.default.removeItem(at: url) }

        try TrainingDataExtractor.writeJSONL(records, to: url)

        let contents = try String(contentsOf: url, encoding: .utf8)
        let lines = contents.split(separator: "\n")
        XCTAssertEqual(lines.count, records.count)

        let decoder = JSONDecoder()
        for line in lines {
            _ = try decoder.decode(TrainingDataExtractor.TrainingRecord.self, from: Data(line.utf8))
        }
    }
}
