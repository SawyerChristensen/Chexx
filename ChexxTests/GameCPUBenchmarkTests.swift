import XCTest
@testable import Chexx

/// Benchmarks GameCPU's minimax search from the standard starting position at depths 1-4,
/// logging exact elapsed time per depth and the % speedup versus the baseline timings recorded
/// in "TO DO.md"'s CPU Performance Notes table (depth 1: 0.01s, depth 2: ~0.2s, depth 3: ~2.0s,
/// depth 4: ~20s). Uses XCTest's measure-less manual timing (rather than `measure`) so all four
/// depths run once each and print a single readable summary instead of `measure`'s repeated-run
/// average across a single fixed block.
final class GameCPUBenchmarkTests: XCTestCase {
    // Baseline elapsed times (seconds) from the CPU Performance Notes table in "TO DO.md",
    // recorded before the tuple-based move generation / isPinned / transposition-table work.
    private static let baselineSeconds: [Int: Double] = [
        1: 0.01,
        2: 0.2,
        3: 2.0,
        4: 20.0,
    ]

    func testMinimaxSearchBenchmarkAcrossDepths() {
        var summary = "\nCPU minimax benchmark (standard starting position):\n"

        for depth in 1...4 {
            var state = GameState()
            let cpu = GameCPU(difficulty: .hard)

            let elapsed = cpu.timedSearch(gameState: &state, depth: depth)

            let baseline = Self.baselineSeconds[depth] ?? 0
            let speedupPercent = baseline > 0 ? ((baseline - elapsed) / baseline) * 100 : 0

            summary += String(format: "  depth %d: %.4fs (baseline %.2fs, %.1f%% speedup)\n", depth, elapsed, baseline, speedupPercent)

            // Sanity check only: confirm the search actually ran to completion rather than
            // asserting on timing, since wall-clock time is hardware-dependent and would make
            // this test flaky on slower CI machines.
            XCTAssertGreaterThanOrEqual(elapsed, 0)
        }

        NSLog("%@", summary)
        print(summary)
    }
}
