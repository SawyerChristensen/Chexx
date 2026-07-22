//
//  GameCPU.swift
//  Chexx
//
//  Created by Sawyer Christensen on 10/25/24.
//

import Foundation

enum CPUDifficulty {
    case random
    case easy
    case medium
    case hard
    case extraHard
}

// A cached minimax result for a position, keyed by its Zobrist hash. `depth` records how deep the
// search below this entry went, so shallower cached results aren't mistaken for deeper ones.
private struct TranspositionEntry {
    let depth: Int
    let value: Int
    let flag: TranspositionFlag
    let bestMove: SearchMove?
}

private enum TranspositionFlag {
    case exact
    case lowerBound // real value is >= `value` (this node caused a beta cutoff)
    case upperBound // real value is <= `value` (this node failed low against alpha)
}

// A move expressed purely as (col,row) board indices, so the search hot path never parses or
// formats algebraic-notation strings. Only the final chosen move is converted to a notation
// string, at the GameCPU/GameScene boundary.
private struct SearchMove: Equatable {
    let fromCol: Int
    let fromRow: Int
    let toCol: Int
    let toRow: Int
    let promotion: String?
}

class GameCPU {
    var difficulty: CPUDifficulty // Enum specifying CPU difficulty level

    // Cleared at the start of every top-level move search (see minimaxMove) so entries never
    // outlive the position they were computed for
    private var transpositionTable: [UInt64: TranspositionEntry] = [:]

    init(difficulty: CPUDifficulty) {
        self.difficulty = difficulty
    }

    // The transposition table key also folds in whose turn it is, since the same piece placement
    // is a different position depending on who's to move
    private func transpositionKey(for gameState: GameState) -> UInt64 {
        gameState.currentPlayer == "black" ? gameState.zobristHash ^ GameState.zobristBlackToMove : gameState.zobristHash
    }

    private func generateAllFullMoves(for color: String, in gameState: inout GameState) -> [SearchMove] {
        var allMoves: [SearchMove] = []

        for colIndex in 0..<GameState.columnSizes.count {
            for rowIndex in 0..<GameState.columnSizes[colIndex] {
                guard let piece = gameState[colIndex, rowIndex], piece.color == color else { continue }
                let validMoves = validMovesForPiece(at: (colIndex, rowIndex), color: piece.color, type: piece.type, in: &gameState)

                // For each valid destination, create a move that includes the start and destination
                for (toCol, toRow) in validMoves {
                    if piece.type == "pawn", isPromotionDestination(toCol, toRow, color: piece.color, in: gameState) {
                        for promotionType in ["queen", "rook", "bishop", "knight"] {
                            allMoves.append(SearchMove(fromCol: colIndex, fromRow: rowIndex, toCol: toCol, toRow: toRow, promotion: promotionType))
                        }
                    } else {
                        allMoves.append(SearchMove(fromCol: colIndex, fromRow: rowIndex, toCol: toCol, toRow: toRow, promotion: nil))
                    }
                }
            }
        }

        return allMoves
    }

    // Whether a pawn moving to this destination would be promoting
    private func isPromotionDestination(_ toCol: Int, _ toRow: Int, color: String, in gameState: GameState) -> Bool {
        color == "white" ? toRow == gameState.rowCount(forCol: toCol) - 1 : toRow == 0
    }

    // Runs a raw minimax search to a fixed depth with an effectively unbounded deadline, so
    // callers get the search's true elapsed time for that depth rather than a time capped by
    // minimaxMove's 3-second cutoff. Used by ChexxTests to benchmark search performance per depth;
    // not used by the app's normal move-selection path (see findMove/minimaxMove).
    func timedSearch(gameState: inout GameState, depth: Int) -> TimeInterval {
        transpositionTable.removeAll()
        let maximizingPlayerColor = gameState.currentPlayer
        let start = Date()
        _ = minimax(gameState: &gameState, depth: depth, alpha: Int.min, beta: Int.max, maximizingPlayer: true, originalPlayerColor: maximizingPlayerColor, deadline: Date.distantFuture)
        return Date().timeIntervalSince(start)
    }

    // The base search depth for each difficulty, before any endgame scaling. nil for .random
    // (which doesn't search at all).
    private static let baseSearchDepth: [CPUDifficulty: Int] = [.easy: 1, .medium: 2, .hard: 3, .extraHard: 5]

    // As the opponent's pieces thin out, the position's branching factor drops sharply, so the
    // search can look further ahead within the same time budget. .easy is deliberately weak and
    // left unscaled. Thresholds count the opponent's pieces including their king.
    private func endgameDepthBonus(opponentPieceCount: Int) -> Int {
        switch opponentPieceCount {
        case ..<4: return 2
        case ..<8: return 1
        default: return 0
        }
    }

    // The search depth findMove will use for the current difficulty and position, or nil for
    // .random (which doesn't search at all). Mirrors the switch in findMove; kept separate so
    // callers can cheaply estimate think time without duplicating findMove's move-selection logic.
    private func resolvedSearchDepth(gameState: inout GameState) -> Int? {
        guard let baseDepth = Self.baseSearchDepth[difficulty] else { return nil }
        guard difficulty != .easy else { return baseDepth }

        let opponentColor = gameState.currentPlayer == "white" ? "black" : "white"
        let opponentPieceCount = gameState.getPieces(for: opponentColor).count
        return baseDepth + endgameDepthBonus(opponentPieceCount: opponentPieceCount)
    }

    // Per-depth search times measured by ChexxTests' CPU search benchmark on the game's starting
    // position (see TO DO.md's "CPU Performance Notes"), against a baseline legal-move count.
    // Used only to guess whether a search is worth showing a "Thinking…" indicator for.
    private static let benchmarkDepthDurations: [Int: TimeInterval] = [1: 0.0003, 2: 0.0092, 3: 0.0207, 4: 0.3831, 5: 2.8505]
    private static let benchmarkMoveCount: Double = 30

    // Cheap legal-move count for the position, exposed so GameScene can scale the thinking-duration
    // estimate below without running (or duplicating) the actual minimax search.
    func legalMoveCount(for gameState: inout GameState) -> Int {
        generateAllFullMoves(for: gameState.currentPlayer, in: &gameState).count
    }

    // Rough guess at how long findMove will take for the current difficulty and position, scaling
    // the recorded benchmark time for this depth by how many legal moves are actually on the board
    // relative to the benchmark's baseline. Not precise — just enough to decide whether the
    // "Thinking…" status text is worth showing. If endgame scaling has pushed the depth past what
    // was benchmarked, falls back to the deepest known benchmark as a floor rather than showing 0.
    func estimatedThinkingDuration(legalMoveCount: Int, gameState: inout GameState) -> TimeInterval {
        guard let depth = resolvedSearchDepth(gameState: &gameState) else { return 0 }
        let knownDepth = min(depth, GameCPU.benchmarkDepthDurations.keys.max() ?? depth)
        guard let baseline = GameCPU.benchmarkDepthDurations[knownDepth] else { return 0 }
        let scale = Double(legalMoveCount) / GameCPU.benchmarkMoveCount
        return baseline * max(scale, 0.1)
    }

    // Main function to decide and make a move
    func findMove(gameState: inout GameState) -> (start: String, destination: String, promotion: String?)? { //this being conditional can maybe be changed, idk
        // Skip the search entirely on the CPU's very first move of the game if a hardcoded
        // opening reply applies (see openingBookMove) — running a full minimax at this stage buys
        // nothing since every reply is roughly equally sound this early
        if let bookMove = openingBookMove(for: &gameState) {
            return bookMove
        }

        // Use the existing function to get all possible moves
        let possibleMoves = generateAllFullMoves(for: gameState.currentPlayer, in: &gameState)

        guard !possibleMoves.isEmpty else {
            return nil // No valid moves available
        }

        guard let depth = resolvedSearchDepth(gameState: &gameState) else {
            return selectRandomMove(from: possibleMoves)
        }
        return minimaxMove(gameState: &gameState, depth: depth)
    }

    // White's starting row in each pawn-bearing column (see GameState.setInitialPiecePositions).
    // Black's starting pawn row is 6 in every one of those columns — a consequence of the board's
    // per-column vertical mirror symmetry between White's and Black's home ranks.
    private static let whitePawnStartRow: [Int: Int] = [1: 0, 2: 1, 3: 2, 4: 3, 5: 4, 6: 3, 7: 2, 8: 1, 9: 0]
    private static let blackPawnStartRow = 6

    // A tiny hardcoded opening book for the CPU's very first move (its reply to White's first
    // move), so the engine can skip minimax entirely at that point. Currently covers White's most
    // common/only-really-available first moves — a single or double pawn push — by mirroring it
    // with Black's pawn in the same column. Anything else (e.g. an opening knight or queen move)
    // returns nil here and falls through to the normal search in findMove.
    private func openingBookMove(for gameState: inout GameState) -> (start: String, destination: String, promotion: String?)? {
        // HexPgn starts with one variant-tag byte, then 2 bytes per move — 3 bytes means exactly
        // White's first move has been played and it's now Black's very first move of the game
        guard gameState.HexPgn.count == 3, gameState.currentPlayer == "black" else { return nil }

        for (col, whiteStartRow) in Self.whitePawnStartRow {
            guard gameState.pieceAt(col: col, row: whiteStartRow) == nil else { continue }

            let pushedRows: Int
            if let p = gameState.pieceAt(col: col, row: whiteStartRow + 1), p.color == "white", p.type == "pawn" {
                pushedRows = 1
            } else if let p = gameState.pieceAt(col: col, row: whiteStartRow + 2), p.color == "white", p.type == "pawn" {
                pushedRows = 2
            } else {
                continue
            }

            let responseFromRow = Self.blackPawnStartRow
            let responseToRow = Self.blackPawnStartRow - pushedRows
            guard let piece = gameState.pieceAt(col: col, row: responseFromRow), piece.color == "black", piece.type == "pawn" else { continue }

            // Safety net: only ever play this if it's genuinely a legal move in the exact current
            // position, so a hardcoded reply can never produce an illegal move
            let legalMoves = validMovesForPiece(at: (col, responseFromRow), color: "black", type: "pawn", in: &gameState)
            guard legalMoves.contains(where: { $0 == (col, responseToRow) }) else { continue }

            let columns = hexColumns
            let start = "\(columns[col])\(responseFromRow + 1)"
            let destination = "\(columns[col])\(responseToRow + 1)"
            return (start, destination, nil)
        }

        return nil
    }

    // Formats a (col,row) search move to algebraic notation. Only called once, at the boundary,
    // for the final move the search/random selection settles on.
    private func notation(for move: SearchMove) -> (start: String, destination: String, promotion: String?) {
        let columns = hexColumns
        let start = "\(columns[move.fromCol])\(move.fromRow + 1)"
        let destination = "\(columns[move.toCol])\(move.toRow + 1)"
        return (start, destination, move.promotion)
    }

    // Randomly select a move
    private func selectRandomMove(from moves: [SearchMove]) -> (start: String, destination: String, promotion: String?)? {
        guard let move = moves.randomElement() else { return nil }
        return notation(for: move)
    }

    private func minimaxMove(gameState: inout GameState, depth: Int) -> (start: String, destination: String, promotion: String?)? {
        // Fresh table per move decision: entries from a prior search are keyed off a board that
        // no longer exists once real moves have been played, so there's nothing to gain by keeping them
        transpositionTable.removeAll()

        let maximizingPlayerColor = gameState.currentPlayer
        let deadline = Date().addingTimeInterval(3.0)
        let bestMove = minimax(gameState: &gameState, depth: depth, alpha: Int.min, beta: Int.max, maximizingPlayer: true, originalPlayerColor: maximizingPlayerColor, deadline: deadline)

        guard let move = bestMove.move else { return nil }
        return notation(for: move)
    }

    private func minimax(gameState: inout GameState, depth: Int, alpha: Int, beta: Int, maximizingPlayer: Bool, originalPlayerColor: String, deadline: Date) -> (value: Int, move: SearchMove?) {
        if depth == 0 {
            let value = evaluateGameState(gameState, for: originalPlayerColor)
            return (value, nil)
        }

        let alphaAtEntry = alpha
        let betaAtEntry = beta

        let ttKey = transpositionKey(for: gameState)
        var ttBestMove: SearchMove? = nil
        if let entry = transpositionTable[ttKey], entry.depth >= depth {
            switch entry.flag {
            case .exact:
                return (entry.value, nil)
            case .lowerBound:
                if entry.value >= beta {
                    return (entry.value, nil)
                }
            case .upperBound:
                if entry.value <= alpha {
                    return (entry.value, nil)
                }
            }
            ttBestMove = entry.bestMove
        }

        var alpha = alpha
        var beta = beta
        var bestValue = maximizingPlayer ? Int.min : Int.max
        var bestMoves: [SearchMove] = [] // List of moves with the best score

        // Generate and order moves for better alpha/beta pruning. An empty result means the side
        // to move has no legal moves (checkmate/stalemate) — this replaces a separate isGameOver()
        // legality scan that used to run first and re-derive the same thing via its own full pass.
        let possibleMoves = generateAllFullMoves(for: gameState.currentPlayer, in: &gameState)
        if possibleMoves.isEmpty {
            let value = evaluateGameState(gameState, for: originalPlayerColor)
            return (value, nil)
        }
        var orderedMoves = orderMoves(possibleMoves, gameState: gameState)

        // Try the transposition table's previously-best move first; it's the move most likely to
        // cause a cutoff, since it was already good enough at this position at an earlier search
        if let ttBestMove = ttBestMove, let ttMoveIndex = orderedMoves.firstIndex(where: { $0 == ttBestMove }) {
            let ttMove = orderedMoves.remove(at: ttMoveIndex)
            orderedMoves.insert(ttMove, at: 0)
        }

        for move in orderedMoves {
            if Date() >= deadline { //mayyyy not need this
                return (bestValue, bestMoves.randomElement())}

            let undoInfo = gameState.makeMove(fromCol: move.fromCol, fromRow: move.fromRow, toCol: move.toCol, toRow: move.toRow, promotionType: move.promotion ?? "queen")
            gameState.currentPlayer = gameState.currentPlayer == "white" ? "black" : "white"

            let result = minimax(
                gameState: &gameState,
                depth: depth - 1,
                alpha: alpha,
                beta: beta,
                maximizingPlayer: !maximizingPlayer,
                originalPlayerColor: originalPlayerColor,
                deadline: deadline)

            gameState.unmakeMove(undoInfo: undoInfo)
            gameState.currentPlayer = gameState.currentPlayer == "white" ? "black" : "white"

            // Update best value and moves based on maximizing/minimizing
            if maximizingPlayer {
                if result.value > bestValue {
                    bestValue = result.value
                    bestMoves = [move]

                } else if result.value == bestValue {
                    bestMoves.append(move)
                }
                alpha = max(alpha, bestValue)
                if beta <= alpha {
                    break // Beta cutoff
                }
            } else {
                if result.value < bestValue {
                    bestValue = result.value
                    bestMoves = [move]
                } else if result.value == bestValue {
                    bestMoves.append(move)
                }
                beta = min(beta, bestValue)
                if beta <= alpha {
                    break // Alpha cutoff
                }
            }
        }

        // Randomly select one of the best moves
        let bestMove = bestMoves.randomElement()

        // Cache this node's result. Whether it's exact or just a bound depends on how bestValue
        // relates to the original alpha/beta window this node was searched with.
        let flag: TranspositionFlag
        if bestValue <= alphaAtEntry {
            flag = .upperBound
        } else if bestValue >= betaAtEntry {
            flag = .lowerBound
        } else {
            flag = .exact
        }
        transpositionTable[ttKey] = TranspositionEntry(depth: depth, value: bestValue, flag: flag, bestMove: bestMove)

        return (bestValue, bestMove)
    }

    // Evaluate the game state to assign a score, using GameState's incrementally-tracked material totals
    private func evaluateGameState(_ gameState: GameState, for player: String) -> Int {
        let playerScore = player == "white" ? gameState.whiteMaterial : gameState.blackMaterial
        let opponentScore = player == "white" ? gameState.blackMaterial : gameState.whiteMaterial

        // Return the material difference
        return playerScore - opponentScore
    }
    
    // Order moves to improve alpha-beta pruning efficiency
    private func orderMoves(_ moves: [SearchMove], gameState: GameState) -> [SearchMove] {
        // Compute each move's score once up front instead of re-deriving it on every
        // comparison the sort performs (sorted's comparator is called O(n log n) times)
        let scoredMoves = moves.map { (move: $0, score: evaluateMove($0, in: gameState)) }
        return scoredMoves.sorted { $0.score > $1.score }.map { $0.move }
    }

    // Simple heuristic to prioritize moves
    private func evaluateMove(_ move: SearchMove, in gameState: GameState) -> Int {
        if let fromPiece = gameState.pieceAt(col: move.fromCol, row: move.fromRow),
           let toPiece = gameState.pieceAt(col: move.toCol, row: move.toRow) {
            // Capture move
            return pieceValue(toPiece.type) - pieceValue(fromPiece.type)
        } else {
            // Non-capture move
            return 0
        }
    }
}
