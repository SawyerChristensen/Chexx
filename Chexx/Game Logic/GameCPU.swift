//
//  GameCPU.swift
//  Chexx
//
//  Created by Sawyer Christensen on 10/25/24.
//

import Foundation

enum CPUDifficulty {
    case easy   // Completely random moves (works)
    case medium // Simple heuristic (e.g., piece count or board control) (doesnt work)
    case hard   // Minimax or another advanced algorithm (doesnt work)
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
    func makeMove(gameState: GameState) -> (start: String, destination: String)? {
        // Use the existing function to get all possible moves
        let possibleMoves = generateAllFullMoves(for: gameState.currentPlayer, in: gameState)

        guard !possibleMoves.isEmpty else {
            return nil // No valid moves available
        }

        switch difficulty {
        case .easy:
            return selectRandomMove(from: possibleMoves)
        case .medium:
            return selectBestMoveWithHeuristic(from: possibleMoves, gameState: gameState)
        case .hard:
            return minimaxMove(gameState: gameState, depth: 3) // Adjust depth as needed
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
        var bestMove: String?
        var bestValue = Int.min

        for move in moves {
            if let parsedMove = parseMove(move) {
                var testState = gameState.copy()
                testState.movePiece(from: parsedMove.start, to: parsedMove.destination)

                let value = evaluateGameState(testState, for: gameState.currentPlayer)
                if value > bestValue {
                    bestValue = value
                    bestMove = move
                }
            }
        }

        if let bestMove = bestMove {
            return parseMove(bestMove)
        }
        return nil
    }

    // Minimax algorithm for Hard difficulty
    private func minimaxMove(gameState: GameState, depth: Int) -> (start: String, destination: String)? {
        let bestMove = minimax(gameState: gameState, depth: depth, maximizingPlayer: true).move
        return parseMove(bestMove)
    }

    // Minimax implementation (simplified)
    private func minimax(gameState: GameState, depth: Int, maximizingPlayer: Bool) -> (value: Int, move: String) {
        if depth == 0 || gameState.isGameOver(for: gameState.currentPlayer).0 {
            let value = evaluateGameState(gameState, for: gameState.currentPlayer)
            return (value, "")
        }

        let possibleMoves = generateAllMoves(for: gameState.currentPlayer, in: gameState)
        var bestValue = maximizingPlayer ? Int.min : Int.max
        var bestMove = ""

        for move in possibleMoves {
            if let parsedMove = parseMove(move) {
                var testState = gameState.copy()
                testState.movePiece(from: parsedMove.start, to: parsedMove.destination)
                testState.currentPlayer = testState.currentPlayer == "white" ? "black" : "white"

                let result = minimax(gameState: testState, depth: depth - 1, maximizingPlayer: !maximizingPlayer)
                if maximizingPlayer {
                    if result.value > bestValue {
                        bestValue = result.value
                        bestMove = move
                    }
                } else {
                    if result.value < bestValue {
                        bestValue = result.value
                        bestMove = move
                    }
                }
            }
        }
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

    // Assign values to pieces for evaluation
    private func pieceValue(_ type: String) -> Int { //could maybe be updated for hexchess specific values
        switch type {
        case "king":
            return 1000
        case "queen":
            return 9
        case "rook":
            return 5
        case "bishop", "knight":
            return 3
        case "pawn":
            return 1
        default:
            return 0
        }
    }
}
