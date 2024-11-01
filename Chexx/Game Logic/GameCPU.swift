//
//  GameCPU.swift
//  Chexx
//
//  Created by Sawyer Christensen on 10/25/24.
//

import Foundation

enum CPUDifficulty {
    case random // Completely random moves (works)
    case easy   // Gains the most points ON the turn (no lookahead)
    case medium // Minimax with a depth of 2
    case hard   // Minimax with a depth of 4-5?
}

class GameCPU {
    var difficulty: CPUDifficulty // Enum specifying CPU difficulty level

    init(difficulty: CPUDifficulty) {
        self.difficulty = difficulty
    }
    
    func generateAllFullMoves(for color: String, in gameState: inout GameState) -> [String] {
        let columns = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "k", "l"]
        var allMoves: [String] = []

        for (colIndex, column) in gameState.board.enumerated() {
            for (rowIndex, piece) in column.enumerated() {
                if let piece = piece, piece.color == color {
                    let currentPosition = "\(columns[colIndex])\(rowIndex + 1)"
                    let validMoves = validMovesForPiece(at: currentPosition, color: piece.color, type: piece.type, in: &gameState)

                    // For each valid destination, create a move string that includes the start and destination
                    for destination in validMoves {
                        let moveString = "\(currentPosition)-\(destination)"
                        allMoves.append(moveString)
                    }
                }
            }
        }

        return allMoves
    }

    // Main function to decide and make a move
    func findMove(gameState: inout GameState) -> (start: String, destination: String)? {
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
    private func selectRandomMove(from moves: [String]) -> (start: String, destination: String)? {
        guard let move = moves.randomElement() else { return nil }
        //print(move)
        return parseMove(move)
    }

    private func minimaxMove(gameState: inout GameState, depth: Int) -> (start: String, destination: String)? {
        
        let startTime = Date() //for testing
        
        let maximizingPlayerColor = gameState.currentPlayer
        let bestMove = minimax(gameState: &gameState, depth: depth, alpha: Int.min, beta: Int.max, maximizingPlayer: true, originalPlayerColor: maximizingPlayerColor).move
        
        let endTime = Date() //for testing
        let timeInterval = endTime.timeIntervalSince(startTime) //for testing
        print("Time taken for minimaxMove: \(timeInterval) seconds")
        
        return parseMove(bestMove)
    }

    private func minimax(gameState: inout GameState, depth: Int, alpha: Int, beta: Int, maximizingPlayer: Bool, originalPlayerColor: String) -> (value: Int, move: String) {
        if depth == 0 || gameState.isGameOver().0 { //need do something and read .1 value if game is actually over
            let value = evaluateGameState(gameState, for: originalPlayerColor)
            return (value, "")
        }

        var alpha = alpha
        var beta = beta
        var bestMoves: [String] = [] // List of moves with the best score
        var bestValue = maximizingPlayer ? Int.min : Int.max

        let possibleMoves = generateAllFullMoves(for: gameState.currentPlayer, in: &gameState)
        let orderedMoves = orderMoves(possibleMoves, gameState: gameState)

        for move in orderedMoves {
            if let parsedMove = parseMove(move) {
                let undoInfo = gameState.makeMove(parsedMove.start, to: parsedMove.destination)
                gameState.currentPlayer = gameState.currentPlayer == "white" ? "black" : "white"

                let result = minimax(gameState: &gameState, depth: depth - 1, alpha: alpha, beta: beta, maximizingPlayer: !maximizingPlayer, originalPlayerColor: originalPlayerColor)

                gameState.unmakeMove(parsedMove.start, to: parsedMove.destination, undoInfo: undoInfo)
                gameState.currentPlayer = gameState.currentPlayer == "white" ? "black" : "white"

                if maximizingPlayer {
                    if result.value > bestValue {
                        bestValue = result.value
                        bestMoves = [move] // Reset bestMoves to the new best move
                    } else if result.value == bestValue {
                        bestMoves.append(move) // Add to bestMoves if it's equal to bestValue
                    }
                    alpha = max(alpha, bestValue)
                    if beta <= alpha {
                        break // Beta cutoff
                    }
                } else {
                    if result.value < bestValue {
                        bestValue = result.value
                        bestMoves = [move] // Reset bestMoves to the new best move
                    } else if result.value == bestValue {
                        bestMoves.append(move) // Add to bestMoves if it's equal to bestValue
                    }
                    beta = min(beta, bestValue)
                    if beta <= alpha {
                        break // Alpha cutoff
                    }
                }
            }
        } //lists can be good for depth of 2, but other depths should have less, better higher scoring moves
        //possible overhead, but nothing important rn. need to figure out hashing and multithreading first

        // Randomly select one of the best moves
        let bestMove = bestMoves.randomElement() ?? ""

        return (bestValue, bestMove)
    }

    // Parse move string into start and destination positions
    private func parseMove(_ move: String) -> (start: String, destination: String)? {
        // Split the move string using the delimiter
        let components = move.split(separator: "-")
        guard components.count == 2 else {
            print("Invalid move format: \(move)")
            return nil
        }
        let start = String(components[0])
        let destination = String(components[1])
        return (start, destination)
    }

    // Evaluate the game state to assign a score
    private func evaluateGameState(_ gameState: GameState, for player: String) -> Int { //this is o^2, can maybe just store a variable that gets updated instead of all of this extra math
        var playerScore = 0
        var opponentScore = 0

        // Iterate over the board to collect pieces
        for column in gameState.board {
            for piece in column {
                if let piece = piece {
                    if piece.color == player {
                        playerScore += pieceValue(piece.type)
                    } else {
                        opponentScore += pieceValue(piece.type)
                    }
                }
            }
        }

        // Return the material difference
        return playerScore - opponentScore
    }
    
    // Order moves to improve alpha-beta pruning efficiency
    private func orderMoves(_ moves: [String], gameState: GameState) -> [String] {
        return moves.sorted { move1, move2 in
            let score1 = evaluateMove(move1, in: gameState)
            let score2 = evaluateMove(move2, in: gameState)
            return score1 > score2
        }
    }

    // Simple heuristic to prioritize moves
    private func evaluateMove(_ move: String, in gameState: GameState) -> Int {
        if let parsedMove = parseMove(move),
           let fromPiece = gameState.pieceAt(parsedMove.start),
           let toPiece = gameState.pieceAt(parsedMove.destination) {
            // Capture move
            return pieceValue(toPiece.type) - pieceValue(fromPiece.type)
        } else {
            // Non-capture move
            return 0
        }
    }
    
    // Assign values to pieces for evaluation
    private func pieceValue(_ type: String) -> Int { //could maybe be updated for hexchess specific values
        switch type {
        case "king":                return 1000
        case "queen":               return 9
        case "rook":                return 5
        case "bishop", "knight":    return 3
        case "pawn":                return 1
        default: return 0
        }
    }
}
