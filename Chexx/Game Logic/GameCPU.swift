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
        // The table is deliberately NOT cleared here: entries are keyed by Zobrist hash (+ side
        // to move), so a stale entry from an earlier position simply never gets looked up again —
        // it's not a correctness risk, just a few extra dictionary entries. Keeping it warm lets
        // this search reuse anything a background ponder() pass already computed for positions
        // reachable from here (see ponder below), instead of throwing that work away.
        let maximizingPlayerColor = gameState.currentPlayer
        let deadline = Date().addingTimeInterval(3.0)

        // Iterative deepening: search depth 1, then 2, ... up to the target depth, stopping early
        // if the deadline is hit. Each iteration populates the transposition table, so the next,
        // deeper iteration finds a ttBestMove to search first — improving move ordering and pruning
        // at every depth instead of only benefiting from within-search TT hits. If a deeper
        // iteration gets cut off partway through by the deadline, the previous fully-searched
        // iteration's move is kept rather than an incomplete one.
        var bestMove: SearchMove? = nil
        for currentDepth in 1...depth {
            if Date() >= deadline { break }
            let result = minimax(gameState: &gameState, depth: currentDepth, alpha: Int.min, beta: Int.max, maximizingPlayer: true, originalPlayerColor: maximizingPlayerColor, deadline: deadline)
            if Date() >= deadline, currentDepth > 1 { break }
            if let move = result.move {
                bestMove = move
            }
        }

        guard let move = bestMove else { return nil }
        return notation(for: move)
    }

    // How long each ponder() search slice runs before checking for cancellation. Short enough
    // that pondering stops promptly once the human moves, long enough to keep iterative-deepening
    // overhead (re-walking already-searched shallow nodes) small relative to useful new work.
    private static let ponderSliceDuration: TimeInterval = 0.25

    // Runs an unbounded iterative-deepening search on `gameState` purely to warm the shared
    // transposition table while it's the human's turn to move, so the real search that follows
    // the human's actual move can reuse whatever overlapping subtrees were already explored.
    // Intended to be called from a background queue and stopped by making `shouldCancel` return
    // true; searches in short time slices and re-checks cancellation between them rather than
    // relying on a single long-running deadline, so it stops promptly instead of running on for
    // an entire deep iteration after it's no longer wanted. Callers must ensure this never runs
    // concurrently with a real findMove/minimaxMove search on the same GameCPU instance (e.g. by
    // dispatching both on the same serial queue) since both mutate transpositionTable.
    //
    // `priorityFromSquare`, if set, is the board square the human currently has selected/tapped —
    // they're most likely about to move that piece, so root moves starting from it are searched
    // (and thus deepened, and cached in the transposition table) before other root moves within
    // each time slice, rather than in whatever order generateAllFullMoves/orderMoves happened to
    // produce.
    func ponder(gameState: GameState, shouldCancel: @escaping () -> Bool, priorityFromSquare: (col: Int, row: Int)? = nil) {
        var searchState = gameState
        let maximizingPlayerColor = searchState.currentPlayer

        var currentDepth = 1
        while !shouldCancel() {
            let sliceDeadline = Date().addingTimeInterval(Self.ponderSliceDuration)
            _ = minimax(gameState: &searchState, depth: currentDepth, alpha: Int.min, beta: Int.max, maximizingPlayer: true, originalPlayerColor: maximizingPlayerColor, deadline: sliceDeadline, priorityFromSquare: priorityFromSquare)

            // Only advance once this depth actually finished within its slice; otherwise retry the
            // same depth next slice, now with a warmer table from the partial work already done.
            if Date() < sliceDeadline {
                currentDepth += 1
            }
        }
    }

    // Null-move pruning parameters: R is how much shallower the "pass" search is run, and
    // minDepth is the shallowest depth it's attempted at (so the reduced search below it, at
    // depth - 1 - R, is never negative).
    private static let nullMoveReduction = 2
    private static let nullMoveMinDepth = 3

    // Late move reduction parameters: once a node's move ordering has already tried its most
    // promising candidates (the TT best move and any high-scoring captures sort near the front —
    // see orderMoves), later quiet moves are unlikely to be best. Search them at a shallower depth
    // first, only paying for a full-depth re-search if that reduced search suggests they might
    // actually beat the current bound. minDepth keeps the reduced search from going below depth 1,
    // and fullSearchMoveCount is how many of a node's earliest moves are always searched at full
    // depth, unreduced.
    private static let lmrReduction = 1
    private static let lmrMinDepth = 3
    private static let lmrFullSearchMoveCount = 3

    // Null-move pruning assumes having the move is always at least as good as not having it, which
    // is false in zugzwang-prone positions — most commonly king-and-pawn-only endgames, where being
    // forced to move can only weaken the position. Skip it there, and skip it whenever the side to
    // move is already in check (passing would leave an illegal, still-in-check "position").
    private func canApplyNullMove(gameState: inout GameState) -> Bool {
        let sideToMove = gameState.currentPlayer
        guard !isKingInCheckUsingKingSight(for: sideToMove, in: &gameState).0 else { return false }
        return gameState.getPieces(for: sideToMove).contains { $0.type != "pawn" && $0.type != "king" }
    }

    private func minimax(gameState: inout GameState, depth: Int, alpha: Int, beta: Int, maximizingPlayer: Bool, originalPlayerColor: String, deadline: Date, isRoot: Bool = true, priorityFromSquare: (col: Int, row: Int)? = nil) -> (value: Int, move: SearchMove?) {
        if depth == 0 {
            let value = evaluateGameState(gameState, for: originalPlayerColor)
            return (value, nil)
        }

        let alphaAtEntry = alpha
        let betaAtEntry = beta

        // Null-move pruning: let the side to move "pass" and search the resulting position — with
        // the opponent effectively granted a free tempo — at a reduced depth. If even that best-case
        // result for the opponent still fails to beat the current bound, a real move can only do
        // better, so this whole subtree is pruned without searching any of its moves. Never applied
        // at the root, since minimaxMove needs an actual move back from that call.
        if !isRoot, depth >= Self.nullMoveMinDepth, Date() < deadline, canApplyNullMove(gameState: &gameState) {
            let sideToMove = gameState.currentPlayer
            gameState.currentPlayer = sideToMove == "white" ? "black" : "white"
            let nullMoveResult = minimax(
                gameState: &gameState,
                depth: depth - 1 - Self.nullMoveReduction,
                alpha: maximizingPlayer ? beta - 1 : alpha,
                beta: maximizingPlayer ? beta : alpha + 1,
                maximizingPlayer: !maximizingPlayer,
                originalPlayerColor: originalPlayerColor,
                deadline: deadline,
                isRoot: false)
            gameState.currentPlayer = sideToMove

            if maximizingPlayer, nullMoveResult.value >= beta {
                return (beta, nil)
            }
            if !maximizingPlayer, nullMoveResult.value <= alpha {
                return (alpha, nil)
            }
        }

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

        // At the root only, if the human has a piece selected, they're most likely about to move
        // it — search those root moves (and thus deepen/cache them) ahead of the rest so pondering
        // spends its limited time on the branches most likely to actually be played.
        if isRoot, let priority = priorityFromSquare {
            orderedMoves = prioritizeMoves(orderedMoves, fromCol: priority.col, fromRow: priority.row)
        }

        // Try the transposition table's previously-best move first; it's the move most likely to
        // cause a cutoff, since it was already good enough at this position at an earlier search
        if let ttBestMove = ttBestMove, let ttMoveIndex = orderedMoves.firstIndex(where: { $0 == ttBestMove }) {
            let ttMove = orderedMoves.remove(at: ttMoveIndex)
            orderedMoves.insert(ttMove, at: 0)
        }

        // Side to move is constant across this whole loop (it only flips once a move is actually
        // made below), so whether it's in check is computed once rather than per candidate move.
        let sideToMoveInCheck = !isRoot && depth >= Self.lmrMinDepth
            ? isKingInCheckUsingKingSight(for: gameState.currentPlayer, in: &gameState).0
            : false

        for (moveIndex, move) in orderedMoves.enumerated() {
            if Date() >= deadline { //mayyyy not need this
                return (bestValue, bestMoves.randomElement())}

            // Late move reduction candidacy is decided before the move is made: it needs the
            // pre-move board (to tell whether the destination square is occupied, i.e. a capture)
            // and the pre-move side to move (already captured above).
            let isLMRCandidate = !isRoot
                && depth >= Self.lmrMinDepth
                && moveIndex >= Self.lmrFullSearchMoveCount
                && move.promotion == nil
                && !sideToMoveInCheck
                && gameState.pieceAt(col: move.toCol, row: move.toRow) == nil

            let undoInfo = gameState.makeMove(fromCol: move.fromCol, fromRow: move.fromRow, toCol: move.toCol, toRow: move.toRow, promotionType: move.promotion ?? "queen")
            gameState.currentPlayer = gameState.currentPlayer == "white" ? "black" : "white"

            var result: (value: Int, move: SearchMove?)
            if isLMRCandidate {
                // Search at reduced depth first. If it still looks good enough to potentially
                // improve this node's bound, it wasn't safe to dismiss at reduced depth — re-search
                // at full depth to get an accurate value before trusting it.
                let reducedDepth = max(1, depth - 1 - Self.lmrReduction)
                result = minimax(
                    gameState: &gameState,
                    depth: reducedDepth,
                    alpha: alpha,
                    beta: beta,
                    maximizingPlayer: !maximizingPlayer,
                    originalPlayerColor: originalPlayerColor,
                    deadline: deadline,
                    isRoot: false)

                let reducedSearchLooksPromising = maximizingPlayer ? result.value > alpha : result.value < beta
                if reducedSearchLooksPromising {
                    result = minimax(
                        gameState: &gameState,
                        depth: depth - 1,
                        alpha: alpha,
                        beta: beta,
                        maximizingPlayer: !maximizingPlayer,
                        originalPlayerColor: originalPlayerColor,
                        deadline: deadline,
                        isRoot: false)
                }
            } else {
                result = minimax(
                    gameState: &gameState,
                    depth: depth - 1,
                    alpha: alpha,
                    beta: beta,
                    maximizingPlayer: !maximizingPlayer,
                    originalPlayerColor: originalPlayerColor,
                    deadline: deadline,
                    isRoot: false)
            }

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

    // Moves the front of `moves` starting from (fromCol, fromRow) to the very front, preserving
    // the existing relative order within both that group and the remainder. Used to bias pondering
    // toward the piece the human currently has selected without disturbing capture-based ordering
    // otherwise.
    private func prioritizeMoves(_ moves: [SearchMove], fromCol: Int, fromRow: Int) -> [SearchMove] {
        let priorityMoves = moves.filter { $0.fromCol == fromCol && $0.fromRow == fromRow }
        guard !priorityMoves.isEmpty else { return moves }
        let remainingMoves = moves.filter { !($0.fromCol == fromCol && $0.fromRow == fromRow) }
        return priorityMoves + remainingMoves
    }
}
