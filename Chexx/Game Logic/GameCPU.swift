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
    func findMove(gameState: inout GameState) -> (start: String, destination: String)? { //this being conditional can maybe be changed, idk
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
        let deadline = startTime.addingTimeInterval(3.0)
        gameState.recomputeMaterial()
        
        let maximizingPlayerColor = gameState.currentPlayer
        let bestMove = minimax(gameState: &gameState, depth: depth, alpha: Int.min, beta: Int.max, maximizingPlayer: true, originalPlayerColor: maximizingPlayerColor, deadline: deadline) //can .move extraction here instead of in the return satement, rn its not for print testing
        
        //print(bestMove)
        
        //let endTime = Date() //for testing
        //let timeInterval = endTime.timeIntervalSince(startTime) //for testing
        //print("Time taken for minimaxMove: \(timeInterval) seconds")
        
        return parseMove(bestMove.move)
    }

    private func minimax(gameState: inout GameState, depth: Int, alpha: Int, beta: Int, maximizingPlayer: Bool, originalPlayerColor: String, deadline: Date) -> (value: Int, move: String) {
        
        //print("Entering minimax at depth:", depth)
        
        if gameState.isGameOver().0 {
            let value = evaluateGameState(gameState, for: originalPlayerColor)
            return (value, "")
        }

        if depth == 0 {
            let value = quiescence(gameState: &gameState, alpha: alpha, beta: beta, maximizingPlayer: maximizingPlayer, originalPlayerColor: originalPlayerColor, deadline: deadline)
            return (value, "")
        }

        var alpha = alpha
        var beta = beta
        var bestValue = maximizingPlayer ? Int.min : Int.max
        var bestMoves: [String] = [] // List of moves with the best score

        // Generate and order moves for better alpha/beta pruning
        let possibleMoves = generateAllFullMoves(for: gameState.currentPlayer, in: &gameState)
        let orderedMoves = orderMoves(possibleMoves, gameState: gameState)

        for move in orderedMoves {
            if Date() >= deadline { //mayyyy not need this
                return (bestValue, bestMoves.randomElement() ?? "")}

            if let parsedMove = parseMove(move) {
                let undoInfo = gameState.makeMove(parsedMove.start, to: parsedMove.destination)
                gameState.currentPlayer = gameState.currentPlayer == "white" ? "black" : "white"

                let result = minimax(
                    gameState: &gameState,
                    depth: depth - 1,
                    alpha: alpha,
                    beta: beta,
                    maximizingPlayer: !maximizingPlayer,
                    originalPlayerColor: originalPlayerColor,
                    deadline: deadline)
                
                //print(result, !maximizingPlayer, gameState.currentPlayer)
                gameState.unmakeMove(parsedMove.start, to: parsedMove.destination, undoInfo: undoInfo)
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
        }

        // Randomly select one of the best moves
        let bestMove = bestMoves.randomElement() ?? ""

        return (bestValue, bestMove)
    }

    private func generateCaptureMoves(for color: String, in gameState: inout GameState) -> [String] {
        let columns = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "k", "l"]
        var captureMoves: [String] = []

        for (colIndex, column) in gameState.board.enumerated() {
            for (rowIndex, piece) in column.enumerated() {
                if let piece = piece, piece.color == color {
                    let currentPosition = "\(columns[colIndex])\(rowIndex + 1)"
                    let validMoves = validMovesForPiece(at: currentPosition, color: piece.color, type: piece.type, in: &gameState)

                    for destination in validMoves {
                        if gameState.pieceAt(destination) != nil {
                            captureMoves.append("\(currentPosition)-\(destination)")
                        }
                    }
                }
            }
        }

        return captureMoves
    }

    private func quiescence(gameState: inout GameState, alpha: Int, beta: Int, maximizingPlayer: Bool, originalPlayerColor: String, deadline: Date) -> Int {
        let standPat = evaluateGameState(gameState, for: originalPlayerColor)

        if Date() >= deadline {
            return standPat
        }

        if maximizingPlayer {
            if standPat >= beta { return beta }
            var alpha = max(alpha, standPat)

            let captureMoves = generateCaptureMoves(for: gameState.currentPlayer, in: &gameState)
            let orderedCaptures = orderMoves(captureMoves, gameState: gameState)

            for move in orderedCaptures {
                if Date() >= deadline { break }
                if let parsedMove = parseMove(move) {
                    let undoInfo = gameState.makeMove(parsedMove.start, to: parsedMove.destination)
                    gameState.currentPlayer = gameState.currentPlayer == "white" ? "black" : "white"

                    let score = quiescence(gameState: &gameState, alpha: alpha, beta: beta, maximizingPlayer: false, originalPlayerColor: originalPlayerColor, deadline: deadline)

                    gameState.unmakeMove(parsedMove.start, to: parsedMove.destination, undoInfo: undoInfo)
                    gameState.currentPlayer = gameState.currentPlayer == "white" ? "black" : "white"

                    alpha = max(alpha, score)
                    if alpha >= beta { break }
                }
            }
            return alpha
        } else {
            if standPat <= alpha { return alpha }
            var beta = min(beta, standPat)

            let captureMoves = generateCaptureMoves(for: gameState.currentPlayer, in: &gameState)
            let orderedCaptures = orderMoves(captureMoves, gameState: gameState)

            for move in orderedCaptures {
                if Date() >= deadline { break }
                if let parsedMove = parseMove(move) {
                    let undoInfo = gameState.makeMove(parsedMove.start, to: parsedMove.destination)
                    gameState.currentPlayer = gameState.currentPlayer == "white" ? "black" : "white"

                    let score = quiescence(gameState: &gameState, alpha: alpha, beta: beta, maximizingPlayer: true, originalPlayerColor: originalPlayerColor, deadline: deadline)

                    gameState.unmakeMove(parsedMove.start, to: parsedMove.destination, undoInfo: undoInfo)
                    gameState.currentPlayer = gameState.currentPlayer == "white" ? "black" : "white"

                    beta = min(beta, score)
                    if alpha >= beta { break }
                }
            }
            return beta
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

    private func evaluateGameState(_ gameState: GameState, for player: String) -> Int {
        if player == "white" {
            return gameState.whiteMaterial - gameState.blackMaterial
        } else {
            return gameState.blackMaterial - gameState.whiteMaterial
        }
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
    
    private func pieceValue(_ type: String) -> Int {
        return GameState.pieceValue(type)
    }
}
