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

    // Main function to decide and make a move
    func findMove(gameState: inout GameState) -> (start: String, destination: String, promotion: String?)? { //this being conditional can maybe be changed, idk
        // Use the existing function to get all possible moves
        let possibleMoves = generateAllFullMoves(for: gameState.currentPlayer, in: &gameState)

        guard !possibleMoves.isEmpty else {
            return nil // No valid moves available
        }

        switch difficulty {
        case .random:
            return selectRandomMove(from: possibleMoves)
        case .easy:
            return minimaxMove(gameState: &gameState, depth: 1)
        case .medium:
            return minimaxMove(gameState: &gameState, depth: 2)
        case .hard:
            return minimaxMove(gameState: &gameState, depth: 3)
        case .extraHard:
            return minimaxMove(gameState: &gameState, depth: 4)
        }
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
