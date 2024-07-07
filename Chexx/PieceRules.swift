//
//  PieceRules.swift
//  Chexx
//
//  Created by Sawyer Christensen on 7/4/24.
//

import Foundation
import SpriteKit

func isValidPosition(columnToCheck: Int, rowToCheck: Int, in gameState: GameState) -> Bool {
    return columnToCheck >= 0 &&
    columnToCheck <= 10 &&
    rowToCheck >= 0 &&
    rowToCheck < gameState.board[columnToCheck].count
}

func boardToHex(_ positions: [(Int, Int)]) -> [String] {
    let columns = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "k", "l"]
    var algebraicPositions: [String] = []
    
    for (colIndex, rowIndex) in positions {
        //guard colIndex >= 0 && colIndex < columns.count else {
        //    continue // Skip invalid column indices
        //}
        
        let columnLetter = columns[colIndex]
        let row = rowIndex + 1 // Assuming the input rowIndex is 0-based and needs to be 1-based
        
        algebraicPositions.append("\(columnLetter)\(row)")
    }
    
    return algebraicPositions
}

func validMovesForPiece(_ piece: SKSpriteNode, in gameState: GameState) -> [String] {
    let pieceDetails = piece.name?.split(separator: "_") ?? []
    guard pieceDetails.count == 3 else { return [] }
    
    let color = String(pieceDetails[1])
    let type = String(pieceDetails[2])
    
    switch type {
    case "pawn":
        return validMovesForPawn(color, at: String(pieceDetails[0]), in: gameState)
    case "rook":
        return validMovesForRook(color, at: String(pieceDetails[0]), in: gameState)
    // Add other piece types here as needed
    default:
        return []
    }
}

//this needs to be changed later and im not doing it now bruh
private func validMovesForPawn(_ color: String, at position: String, in gameState: GameState) -> [String] {
    let columns = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "k", "l"]
    var validBoardMoves: [(Int, Int)] = []

    guard position.count >= 2, //this is a tad silly, could maybe remove this but I guess more error checking doesnt hurt
          let columnLetter = position.first,
          var rowIndex = Int(String(position.dropFirst())),
          let colIndex = columns.firstIndex(of: String(columnLetter)) else {
        print("Position only has string length of 1!")
        return boardToHex(validBoardMoves)
    }
    rowIndex = rowIndex - 1 // making it 0 indexed to work with gameState.board

    if color == "white" {
        // Move up 1
        if isValidPosition(columnToCheck: colIndex, rowToCheck: rowIndex + 1, in: gameState),
           gameState.board[colIndex][rowIndex + 1] == nil {
            validBoardMoves.append((colIndex, rowIndex + 1))

            // If it hasn't moved at all, bonus move!
            if !gameState.board[colIndex][rowIndex]!.hasMoved,
               gameState.board[colIndex][rowIndex + 2] == nil {
                validBoardMoves.append((colIndex, rowIndex + 2)) // opening bonus 2 tiles!
            }
        }
        // Capture logic for left and right
        if colIndex < 5 { // Left side of board
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex, in: gameState), //left on left
               gameState.board[colIndex - 1][rowIndex]?.color == "black" {
                validBoardMoves.append((colIndex - 1, rowIndex))
            }
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex + 1, in: gameState), //right on left
               gameState.board[colIndex + 1][rowIndex + 1]?.color == "black" {
                validBoardMoves.append((colIndex + 1, rowIndex + 1))
            }
        } else if colIndex == 5 { // Center of board
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex, in: gameState), //left on center
               gameState.board[colIndex - 1][rowIndex]?.color == "black" {
                validBoardMoves.append((colIndex - 1, rowIndex))
            }
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex, in: gameState), //right on center
               gameState.board[colIndex + 1][rowIndex]?.color == "black" {
                validBoardMoves.append((colIndex + 1, rowIndex))
            }
        } else { // Right side of board
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex + 1, in: gameState), //left on right
               gameState.board[colIndex - 1][rowIndex + 1]?.color == "black" {
                validBoardMoves.append((colIndex - 1, rowIndex + 1))
            }
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex, in: gameState), //right on right
               gameState.board[colIndex + 1][rowIndex]?.color == "black" {
                validBoardMoves.append((colIndex + 1, rowIndex))
            }
        }
    }

    if color == "black" {
        // Move down 1
        if isValidPosition(columnToCheck: colIndex, rowToCheck: rowIndex - 1, in: gameState),
           gameState.board[colIndex][rowIndex - 1] == nil {
            validBoardMoves.append((colIndex, rowIndex - 1))

            // If it hasn't moved at all, bonus move!
            if !gameState.board[colIndex][rowIndex]!.hasMoved,
               gameState.board[colIndex][rowIndex - 2] == nil {
                validBoardMoves.append((colIndex, rowIndex - 2)) // opening bonus 2 tiles!
            }
        }
        // Capture logic for left and right
        if colIndex < 5 { // Left side of board
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex - 1, in: gameState),
               gameState.board[colIndex - 1][rowIndex - 1]?.color == "white" {
                validBoardMoves.append((colIndex - 1, rowIndex - 1))
            }
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex, in: gameState),
               gameState.board[colIndex + 1][rowIndex]?.color == "white" {
                validBoardMoves.append((colIndex + 1, rowIndex))
            }
        } else if colIndex == 5 { // Center of board
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex - 1, in: gameState),
               gameState.board[colIndex - 1][rowIndex - 1]?.color == "white" {
                validBoardMoves.append((colIndex - 1, rowIndex - 1))
            }
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex - 1, in: gameState),
               gameState.board[colIndex + 1][rowIndex - 1]?.color == "white" {
                validBoardMoves.append((colIndex + 1, rowIndex - 1))
            }
        } else { // Right side of board
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex, in: gameState),
               gameState.board[colIndex - 1][rowIndex]?.color == "white" {
                validBoardMoves.append((colIndex - 1, rowIndex))
            }
            if colIndex + 1 < columns.count,
               isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex - 1, in: gameState),
               gameState.board[colIndex + 1][rowIndex - 1]?.color == "white" {
                validBoardMoves.append((colIndex + 1, rowIndex - 1))
            }
        }
    }
    return boardToHex(validBoardMoves)
}

private func validMovesForRook(_ color: String, at position: String, in gameState: GameState) -> [String] {
    let columns = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "k", "l"]
    var validBoardMoves: [(Int, Int)] = []

    guard position.count >= 2,
          let columnLetter = position.first,
          var rowIndex = Int(String(position.dropFirst())),
          let colIndex = columns.firstIndex(of: String(columnLetter)) else {
        print("Position only has string length of 1!")
        return boardToHex(validBoardMoves)
    }
    rowIndex = rowIndex - 1 // making it 0 indexed to work with gameState.board

    // Rook moves in four directions: up, down, left, right

    // Move up
    var counter = 1
    while isValidPosition(columnToCheck: colIndex, rowToCheck: rowIndex + counter, in: gameState) {
        if gameState.board[colIndex][rowIndex + counter] == nil {
            validBoardMoves.append((colIndex, rowIndex + counter))
        } else if gameState.board[colIndex][rowIndex + counter]?.color == color {
            break
        } else {
            validBoardMoves.append((colIndex, rowIndex + counter))
            break
        }
        counter += 1
    }

    // Move down
    counter = 1
    while isValidPosition(columnToCheck: colIndex, rowToCheck: rowIndex - counter, in: gameState) {
        if gameState.board[colIndex][rowIndex - counter] == nil {
            validBoardMoves.append((colIndex, rowIndex - counter))
        } else if gameState.board[colIndex][rowIndex - counter]?.color == color {
            break
        } else {
            validBoardMoves.append((colIndex, rowIndex - counter))
            break
        }
        counter += 1
    }

    // Move up left...
    counter = 1

        // ...on the right side of the board
        while colIndex - counter >= 5 && isValidPosition(columnToCheck: colIndex - counter, rowToCheck: rowIndex + counter, in: gameState) {
            if gameState.board[colIndex - counter][rowIndex + counter] == nil {
                validBoardMoves.append((colIndex - counter, rowIndex + counter))
            } else if gameState.board[colIndex - counter][rowIndex + counter]?.color == color {
                break
            } else {
                validBoardMoves.append((colIndex - counter, rowIndex + counter))
                break
            }
            counter += 1
        }

        var new_starting_row = rowIndex + counter - 1

        // ...on the middle/left side of the board
        while colIndex - counter < 5 && isValidPosition(columnToCheck: colIndex - counter, rowToCheck: new_starting_row, in: gameState) {
            if gameState.board[colIndex - counter][new_starting_row] == nil {
                validBoardMoves.append((colIndex - counter, new_starting_row))
            } else if gameState.board[colIndex - counter][new_starting_row]?.color == color {
                break
            } else {
                validBoardMoves.append((colIndex - counter, new_starting_row))
                break
            }
            counter += 1
            }

    // Move up right...
    counter = 1
    
        // ...on the left side of the board
        while colIndex + counter <= 5 && isValidPosition(columnToCheck: colIndex + counter, rowToCheck: rowIndex + counter, in: gameState) {
            if gameState.board[colIndex + counter][rowIndex + counter] == nil {
                validBoardMoves.append((colIndex + counter, rowIndex + counter))
            } else if gameState.board[colIndex + counter][rowIndex + counter]?.color == color {
                break
            } else {
                validBoardMoves.append((colIndex + counter, rowIndex + counter))
                break
            }
            counter += 1
        }

        new_starting_row = rowIndex + counter - 1

        // ...on the middle/right side of the board
        while colIndex + counter > 5 && isValidPosition(columnToCheck: colIndex + counter, rowToCheck: new_starting_row, in: gameState) {
            if gameState.board[colIndex + counter][new_starting_row] == nil {
                validBoardMoves.append((colIndex + counter, new_starting_row))
            } else if gameState.board[colIndex + counter][new_starting_row]?.color == color {
                break
            } else {
                validBoardMoves.append((colIndex + counter, new_starting_row))
                break
            }
            counter += 1
        }
    
    // Move down left...
    counter = 1
    
        // ...on the right side of the board NOT WORKING
        while colIndex - counter >= 5 && isValidPosition(columnToCheck: colIndex - counter, rowToCheck: rowIndex, in: gameState) {
            if gameState.board[colIndex - counter][rowIndex] == nil {
                validBoardMoves.append((colIndex - counter, rowIndex))
            } else if gameState.board[colIndex - counter][rowIndex]?.color == color {
                break
            } else {
                validBoardMoves.append((colIndex - counter, rowIndex))
                break
            }
            counter += 1
        }

        new_starting_row = rowIndex + counter - 1
        // ...on the middle/left side of the board
        while colIndex - counter < 5 && isValidPosition(columnToCheck: colIndex - counter, rowToCheck: new_starting_row - counter, in: gameState) {
            if gameState.board[colIndex - counter][new_starting_row - counter] == nil {
                validBoardMoves.append((colIndex - counter, new_starting_row - counter))
            } else if gameState.board[colIndex - counter][new_starting_row - counter]?.color == color {
                break
            } else {
                validBoardMoves.append((colIndex - counter, new_starting_row - counter))
                break
            }
            counter += 1
        }

    // Move down right...
    counter = 1
    
        // ...on the left side of the board NOT WORKING
        while colIndex + counter <= 5 && isValidPosition(columnToCheck: colIndex + counter, rowToCheck: rowIndex, in: gameState) {
            if gameState.board[colIndex + counter][rowIndex] == nil {
                validBoardMoves.append((colIndex + counter, rowIndex))
            } else if gameState.board[colIndex + counter][rowIndex]?.color == color {
                break
            } else {
                validBoardMoves.append((colIndex + counter, rowIndex))
                break
            }
            counter += 1
        }

        new_starting_row = rowIndex + counter - 1
    
        // ...on the middle/right side of the board
        while colIndex + counter > 5 && isValidPosition(columnToCheck: colIndex + counter, rowToCheck: new_starting_row - counter, in: gameState) {
            if gameState.board[colIndex + counter][new_starting_row - counter] == nil {
                validBoardMoves.append((colIndex + counter, new_starting_row - counter))
            } else if gameState.board[colIndex + counter][new_starting_row - counter]?.color == color {
                break
            } else {
                validBoardMoves.append((colIndex + counter, new_starting_row - counter))
                break
            }
            counter += 1
        }

    return boardToHex(validBoardMoves)
}
