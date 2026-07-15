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
}

// A cached minimax result for a position, keyed by its Zobrist hash. `depth` records how deep the
// search below this entry went, so shallower cached results aren't mistaken for deeper ones.
private struct TranspositionEntry {
    let depth: Int
    let value: Int
    let flag: TranspositionFlag
    let bestMove: String
}

private enum TranspositionFlag {
    case exact
    case lowerBound // real value is >= `value` (this node caused a beta cutoff)
    case upperBound // real value is <= `value` (this node failed low against alpha)
}

// A move with its start/destination/promotion already split out, computed once at generation
// time so the search hot path never re-parses a "A1-B2=queen"-style string.
private struct SearchMove {
    let notation: String
    let start: String
    let destination: String
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
        let columns = hexColumns
        var allMoves: [SearchMove] = []

        for colIndex in 0..<GameState.columnSizes.count {
            for rowIndex in 0..<GameState.columnSizes[colIndex] {
                guard let piece = gameState[colIndex, rowIndex], piece.color == color else { continue }
                let currentPosition = "\(columns[colIndex])\(rowIndex + 1)"
                let validMoves = validMovesForPiece(at: currentPosition, color: piece.color, type: piece.type, in: &gameState)

                // For each valid destination, create a move that includes the start and destination
                for destination in validMoves {
                    if piece.type == "pawn", isPromotionDestination(destination, color: piece.color, in: gameState) {
                        for promotionType in ["queen", "rook", "bishop", "knight"] {
                            allMoves.append(SearchMove(notation: "\(currentPosition)-\(destination)=\(promotionType)", start: currentPosition, destination: destination, promotion: promotionType))
                        }
                    } else {
                        allMoves.append(SearchMove(notation: "\(currentPosition)-\(destination)", start: currentPosition, destination: destination, promotion: nil))
                    }
                }
            }
        }

        return allMoves
    }

    // Whether a pawn moving to this destination would be promoting
    private func isPromotionDestination(_ destination: String, color: String, in gameState: GameState) -> Bool {
        let columns = hexColumns
        guard let colLetter = destination.first,
              let colIndex = columns.firstIndex(of: String(colLetter)),
              let rowIndex = Int(destination.dropFirst()).map({ $0 - 1 }) else {
            return false
        }
        return color == "white" ? rowIndex == gameState.rowCount(forCol: colIndex) - 1 : rowIndex == 0
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
        }
    }

    // Randomly select a move
    private func selectRandomMove(from moves: [SearchMove]) -> (start: String, destination: String, promotion: String?)? {
        guard let move = moves.randomElement() else { return nil }
        return (move.start, move.destination, move.promotion)
    }

    private func minimaxMove(gameState: inout GameState, depth: Int) -> (start: String, destination: String, promotion: String?)? {
        // Fresh table per move decision: entries from a prior search are keyed off a board that
        // no longer exists once real moves have been played, so there's nothing to gain by keeping them
        transpositionTable.removeAll()

        let maximizingPlayerColor = gameState.currentPlayer
        let deadline = Date().addingTimeInterval(3.0)
        let bestMove = minimax(gameState: &gameState, depth: depth, alpha: Int.min, beta: Int.max, maximizingPlayer: true, originalPlayerColor: maximizingPlayerColor, deadline: deadline)

        guard let move = bestMove.move else { return nil }
        return (move.start, move.destination, move.promotion)
    }

    private func minimax(gameState: inout GameState, depth: Int, alpha: Int, beta: Int, maximizingPlayer: Bool, originalPlayerColor: String, deadline: Date) -> (value: Int, move: SearchMove?) {
        if depth == 0 || gameState.isGameOver().0 {
            let value = evaluateGameState(gameState, for: originalPlayerColor)
            return (value, nil)
        }

        let alphaAtEntry = alpha
        let betaAtEntry = beta

        let ttKey = transpositionKey(for: gameState)
        var ttBestMoveNotation: String? = nil
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
            ttBestMoveNotation = entry.bestMove
        }

        var alpha = alpha
        var beta = beta
        var bestValue = maximizingPlayer ? Int.min : Int.max
        var bestMoves: [SearchMove] = [] // List of moves with the best score

        // Generate and order moves for better alpha/beta pruning
        let possibleMoves = generateAllFullMoves(for: gameState.currentPlayer, in: &gameState)
        var orderedMoves = orderMoves(possibleMoves, gameState: gameState)

        // Try the transposition table's previously-best move first; it's the move most likely to
        // cause a cutoff, since it was already good enough at this position at an earlier search
        if let ttBestMoveNotation = ttBestMoveNotation, let ttMoveIndex = orderedMoves.firstIndex(where: { $0.notation == ttBestMoveNotation }) {
            let ttMove = orderedMoves.remove(at: ttMoveIndex)
            orderedMoves.insert(ttMove, at: 0)
        }

        for move in orderedMoves {
            if Date() >= deadline { //mayyyy not need this
                return (bestValue, bestMoves.randomElement())}

            let undoInfo = gameState.makeMove(move.start, to: move.destination, promotionType: move.promotion ?? "queen")
            gameState.currentPlayer = gameState.currentPlayer == "white" ? "black" : "white"

            let result = minimax(
                gameState: &gameState,
                depth: depth - 1,
                alpha: alpha,
                beta: beta,
                maximizingPlayer: !maximizingPlayer,
                originalPlayerColor: originalPlayerColor,
                deadline: deadline)

            gameState.unmakeMove(move.start, to: move.destination, undoInfo: undoInfo)
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
        transpositionTable[ttKey] = TranspositionEntry(depth: depth, value: bestValue, flag: flag, bestMove: bestMove?.notation ?? "")

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
        if let fromPiece = gameState.pieceAt(move.start),
           let toPiece = gameState.pieceAt(move.destination) {
            // Capture move
            return pieceValue(toPiece.type) - pieceValue(fromPiece.type)
        } else {
            // Non-capture move
            return 0
        }
    }
}
