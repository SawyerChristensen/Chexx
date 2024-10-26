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
    
    func generateAllFullMoves(for color: String, in gameState: GameState) -> [String] {
        let columns = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "k", "l"]
        var allMoves: [String] = []

        for (colIndex, column) in gameState.board.enumerated() {
            for (rowIndex, piece) in column.enumerated() {
                if let piece = piece, piece.color == color {
                    let currentPosition = "\(columns[colIndex])\(rowIndex + 1)"
                    let validMoves = validMovesForPiece(at: currentPosition, color: piece.color, type: piece.type, in: gameState, skipKingCheck: true)

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
    func findMove(gameState: GameState) -> (start: String, destination: String)? {
        // Use the existing function to get all possible moves
        let possibleMoves = generateAllFullMoves(for: gameState.currentPlayer, in: gameState)

        guard !possibleMoves.isEmpty else {
            return nil // No valid moves available
        }

        switch difficulty {
        case .random:
            return selectRandomMove(from: possibleMoves)
        case .easy:
            return selectBestMoveWithHeuristic(from: possibleMoves, gameState: gameState) //depth of 1?
        case .medium:
            return minimaxMove(gameState: gameState, depth: 2)
        case .hard:
            return minimaxMove(gameState: gameState, depth: 3)
        }
    }

    // Randomly select a move (Easy difficulty)
    private func selectRandomMove(from moves: [String]) -> (start: String, destination: String)? {
        guard let move = moves.randomElement() else { return nil }
        print(move)
        return parseMove(move)
    }

    // Heuristic-based move selection (Medium difficulty)
    private func selectBestMoveWithHeuristic(from moves: [String], gameState: GameState) -> (start: String, destination: String)? {
        var bestMoves: [String] = []
        var bestValue = Int.min

        for move in moves {
            if let parsedMove = parseMove(move) {
                var testState = gameState.copy()
                testState.movePiece(from: parsedMove.start, to: parsedMove.destination)

                let value = evaluateGameState(testState, for: gameState.currentPlayer)
                if value > bestValue {
                    bestValue = value
                    bestMoves = [move] // Start a new list with this move
                } else if value == bestValue {
                    bestMoves.append(move)
                }
            }
        }

        if !bestMoves.isEmpty {
            // Randomly select one move among the best moves
            if let selectedMove = bestMoves.randomElement() {
                print("Selected move among best moves: \(selectedMove)")
                return parseMove(selectedMove)
            }
        }
        return nil
    }

    // Minimax algorithm for Hard difficulty
    private func minimaxMove(gameState: GameState, depth: Int) -> (start: String, destination: String)? {
        
        let startTime = Date() //for testing
        
        let maximizingPlayerColor = gameState.currentPlayer
        let bestMove = minimax(gameState: gameState, depth: depth, alpha: Int.min, beta: Int.max, maximizingPlayer: true, originalPlayerColor: maximizingPlayerColor).move
        
        // Record the end time
        let endTime = Date()
        // Calculate the time interval (in seconds)
        let timeInterval = endTime.timeIntervalSince(startTime)
        // Print the time taken
        print("Time taken for minimaxMove: \(timeInterval) seconds")
        
        return parseMove(bestMove)
    }

    // Minimax implementation (simplified)
    private func minimax(gameState: GameState, depth: Int, alpha: Int, beta: Int, maximizingPlayer: Bool, originalPlayerColor: String) -> (value: Int, move: String) {
        if depth == 0 || gameState.isGameOver().0 { //need do something and read .1 value if game is actually over
            let value = evaluateGameState(gameState, for: originalPlayerColor)
            return (value, "")
        }
        //print("thinking...")

        var alpha = alpha
        var beta = beta
        var bestMove = ""

        let possibleMoves = generateAllFullMoves(for: gameState.currentPlayer, in: gameState)

        if maximizingPlayer {
            var bestValue = Int.min
            for move in possibleMoves {
                if let parsedMove = parseMove(move) {
                    var testState = gameState.copy()
                    testState.movePiece(from: parsedMove.start, to: parsedMove.destination)
                    testState.currentPlayer = testState.currentPlayer == "white" ? "black" : "white"

                    let result = minimax(gameState: testState, depth: depth - 1, alpha: alpha, beta: beta, maximizingPlayer: false, originalPlayerColor: originalPlayerColor)
                    if result.value > bestValue {
                        bestValue = result.value
                        bestMove = move
                    }
                    alpha = max(alpha, bestValue)
                    if beta <= alpha {
                        break // Beta cutoff
                    }
                }
            }
            return (bestValue, bestMove)
        } else {
            var bestValue = Int.max
            for move in possibleMoves {
                if let parsedMove = parseMove(move) {
                    var testState = gameState.copy()
                    testState.movePiece(from: parsedMove.start, to: parsedMove.destination)
                    testState.currentPlayer = testState.currentPlayer == "white" ? "black" : "white"

                    let result = minimax(gameState: testState, depth: depth - 1, alpha: alpha, beta: beta, maximizingPlayer: true, originalPlayerColor: originalPlayerColor)
                    if result.value < bestValue {
                        bestValue = result.value
                        bestMove = move
                    }
                    beta = min(beta, bestValue)
                    if beta <= alpha {
                        break // Alpha cutoff
                    }
                }
            }
            //print("thunk")
            return (bestValue, bestMove)
        }
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
    private func evaluateGameState(_ gameState: GameState, for player: String) -> Int {
        // Initialize scores
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
