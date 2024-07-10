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
    case "bishop":
        return validMovesForBishop(color, at: String(pieceDetails[0]), in: gameState)
    case "queen":
        let rookMoves = validMovesForRook(color, at: String(pieceDetails[0]), in: gameState)
        let bishopMoves = validMovesForBishop(color, at: String(pieceDetails[0]), in: gameState)
        return Array(Set(rookMoves + bishopMoves))
    case "king":
        return validMovesForKing(color, at: String(pieceDetails[0]), in: gameState)
    default:
        return []
    }
}

//this needs to be changed later to make promotion work!!
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
        print("Position only has string length of 1??")
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

        // ...on the middle/left side of the board
        var new_starting_row = rowIndex + counter - 1
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

        // ...on the middle/right side of the board
        new_starting_row = rowIndex + counter - 1
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
    
        // ...on the right side of the board
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

        // ...on the middle/left side of the board
        new_starting_row = rowIndex + counter - 1
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
    
        // ...on the left side of the board
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
    
        // ...on the middle/right side of the board
        new_starting_row = rowIndex + counter - 1
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

private func validMovesForBishop(_ color: String, at position: String, in gameState: GameState) -> [String] {
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
    
    // Bishop moves in six diagonal directions: up left, up right, down left, down right, perfect left, perfect right
    
    // Move up left diagonal...
    var counter = 1
    
        // ...on the right side of the board
        while colIndex - counter >= 5 && isValidPosition(columnToCheck: colIndex - counter, rowToCheck: rowIndex + (counter * 2), in: gameState) {
            if gameState.board[colIndex - counter][rowIndex + (counter * 2)] == nil {
                validBoardMoves.append((colIndex - counter, rowIndex + (counter * 2)))
            } else if gameState.board[colIndex - counter][rowIndex + (counter * 2)]?.color == color {
                break
            } else {
                validBoardMoves.append((colIndex - counter, rowIndex + (counter * 2)))
                break
            }
            counter += 1
        }
        
        // ...on the middle/left side of the board
        var new_starting_row = rowIndex + counter - 1
        while colIndex - counter < 5 && isValidPosition(columnToCheck: colIndex - counter, rowToCheck: new_starting_row + counter, in: gameState) {
            if gameState.board[colIndex - counter][new_starting_row + counter] == nil {
                validBoardMoves.append((colIndex - counter, new_starting_row + counter))
            } else if gameState.board[colIndex - counter][new_starting_row + counter]?.color == color {
                break
            } else {
                validBoardMoves.append((colIndex - counter, new_starting_row + counter))
                break
            }
            counter += 1
        }
    
    // Move up right diagonal...
    counter = 1
    
        // ...on the left side of the board
        while colIndex + counter <= 5 && isValidPosition(columnToCheck: colIndex + counter, rowToCheck: rowIndex + (counter * 2), in: gameState) {
            if gameState.board[colIndex + counter][rowIndex + (counter * 2)] == nil {
                validBoardMoves.append((colIndex + counter, rowIndex + (counter * 2)))
            } else if gameState.board[colIndex + counter][rowIndex + (counter * 2)]?.color == color {
                break
            } else {
                validBoardMoves.append((colIndex + counter, rowIndex + (counter * 2)))
                break
            }
            counter += 1
        }

        // ...on the middle/right side of the board
        new_starting_row = rowIndex + counter - 1
        while colIndex + counter > 5 && isValidPosition(columnToCheck: colIndex + counter, rowToCheck: new_starting_row + counter, in: gameState) {
            if gameState.board[colIndex + counter][new_starting_row + counter] == nil {
                validBoardMoves.append((colIndex + counter, new_starting_row + counter))
            } else if gameState.board[colIndex + counter][new_starting_row + counter]?.color == color {
                break
            } else {
                validBoardMoves.append((colIndex + counter, new_starting_row + counter))
                break
            }
            counter += 1
        }
    
    // Move down left diagonal...
    counter = 1
    
        // ...on the right side of the board
        while colIndex - counter >= 5 && isValidPosition(columnToCheck: colIndex - counter, rowToCheck: rowIndex - counter, in: gameState) {
            if gameState.board[colIndex - counter][rowIndex - counter] == nil {
                validBoardMoves.append((colIndex - counter, rowIndex - counter))
            } else if gameState.board[colIndex - counter][rowIndex - counter]?.color == color {
                break
            } else {
                validBoardMoves.append((colIndex - counter, rowIndex - counter))
                break
            }
            counter += 1
        }

        // ...on the middle/left side of the board
        new_starting_row = rowIndex - counter + 1
        while colIndex - counter < 5 && isValidPosition(columnToCheck: colIndex - counter, rowToCheck: new_starting_row - (counter * 2), in: gameState) {
            if gameState.board[colIndex - counter][new_starting_row - (counter * 2)] == nil {
                validBoardMoves.append((colIndex - counter, new_starting_row - (counter * 2)))
            } else if gameState.board[colIndex - counter][new_starting_row - (counter * 2)]?.color == color {
                break
            } else {
                validBoardMoves.append((colIndex - counter, new_starting_row - (counter * 2)))
                break
            }
            counter += 1
        }
    
    // Move down right diagonal...
    counter = 1
    
        // ...on the left side of the board
        while colIndex + counter <= 5 && isValidPosition(columnToCheck: colIndex + counter, rowToCheck: rowIndex - counter, in: gameState) {
            if gameState.board[colIndex + counter][rowIndex - counter] == nil {
                validBoardMoves.append((colIndex + counter, rowIndex - counter))
            } else if gameState.board[colIndex + counter][rowIndex - counter]?.color == color {
                break
            } else {
                validBoardMoves.append((colIndex + counter, rowIndex - counter))
                break
            }
            counter += 1
        }

        // ...on the middle/right side of the board
        new_starting_row = rowIndex - counter + 1
        while colIndex + counter > 5 && isValidPosition(columnToCheck: colIndex + counter, rowToCheck: new_starting_row - (counter * 2), in: gameState) {
            if gameState.board[colIndex + counter][new_starting_row - (counter * 2)] == nil {
                validBoardMoves.append((colIndex + counter, new_starting_row - (counter * 2)))
            } else if gameState.board[colIndex + counter][new_starting_row - (counter * 2)]?.color == color {
                break
            } else {
                validBoardMoves.append((colIndex + counter, new_starting_row - (counter * 2)))
                break
            }
            counter += 1
        }
    
    // Move perfectly left...
    counter = 1
    
        // ...on the right side of the board
        while colIndex - (counter * 2) > 4 && isValidPosition(columnToCheck: colIndex - (counter * 2), rowToCheck: rowIndex + counter, in: gameState) {
            if gameState.board[colIndex - (counter * 2)][rowIndex + counter] == nil {
                validBoardMoves.append((colIndex - (counter * 2), rowIndex + counter))
            } else if gameState.board[colIndex - (counter * 2)][rowIndex + counter]?.color == color {
                break
            } else {
                validBoardMoves.append((colIndex - (counter * 2), rowIndex + counter))
                break
            }
            counter += 1
        }

        // ...crossing the middle column
        new_starting_row = rowIndex + counter - 1
        while colIndex - (counter * 2) == 4 && isValidPosition(columnToCheck: colIndex - (counter * 2), rowToCheck: new_starting_row, in: gameState) {
            if gameState.board[colIndex - (counter * 2)][new_starting_row] == nil {
                validBoardMoves.append((colIndex - (counter * 2), new_starting_row))
            } else if gameState.board[colIndex - (counter * 2)][new_starting_row]?.color == color {
                break
            } else {
                validBoardMoves.append((colIndex - (counter * 2), new_starting_row))
                break
            }
            counter += 1
        }

        // ...on the left side of the board
        new_starting_row = new_starting_row + counter - 1
        while colIndex - (counter * 2) < 4 && isValidPosition(columnToCheck: colIndex - (counter * 2), rowToCheck: new_starting_row - counter, in: gameState) {
            if gameState.board[colIndex - (counter * 2)][new_starting_row - counter] == nil {
                validBoardMoves.append((colIndex - (counter * 2), new_starting_row - counter))
            } else if gameState.board[colIndex - (counter * 2)][new_starting_row - counter]?.color == color {
                break
            } else {
                validBoardMoves.append((colIndex - (counter * 2), new_starting_row - counter))
                break
            }
            counter += 1
        }
    
    // Move perfectly right...
    counter = 1
    
        // ...on the left side of the board
        while colIndex + (counter * 2) < 6 && isValidPosition(columnToCheck: colIndex + (counter * 2), rowToCheck: rowIndex + counter, in: gameState) {
            if gameState.board[colIndex + (counter * 2)][rowIndex + counter] == nil {
                validBoardMoves.append((colIndex + (counter * 2), rowIndex + counter))
            } else if gameState.board[colIndex + (counter * 2)][rowIndex + counter]?.color == color {
                break
            } else {
                validBoardMoves.append((colIndex + (counter * 2), rowIndex + counter))
                break
            }
            counter += 1
        }

        // ...crossing the middle column
        new_starting_row = rowIndex + counter - 1
        while colIndex + (counter * 2) == 6 && isValidPosition(columnToCheck: colIndex + (counter * 2), rowToCheck: new_starting_row, in: gameState) {
            if gameState.board[colIndex + (counter * 2)][new_starting_row] == nil {
                validBoardMoves.append((colIndex + (counter * 2), new_starting_row))
            } else if gameState.board[colIndex + (counter * 2)][new_starting_row]?.color == color {
                break
            } else {
                validBoardMoves.append((colIndex + (counter * 2), new_starting_row))
                break
            }
            counter += 1
        }

        // ...on the right side of the board
        new_starting_row = new_starting_row + counter - 1
        while colIndex + (counter * 2) > 6 && isValidPosition(columnToCheck: colIndex + (counter * 2), rowToCheck: new_starting_row - counter, in: gameState) {
            if gameState.board[colIndex + (counter * 2)][new_starting_row - counter] == nil {
                validBoardMoves.append((colIndex + (counter * 2), new_starting_row - counter))
            } else if gameState.board[colIndex + (counter * 2)][new_starting_row - counter]?.color == color {
                break
            } else {
                validBoardMoves.append((colIndex + (counter * 2), new_starting_row - counter))
                break
            }
            counter += 1
        }

    return boardToHex(validBoardMoves)
}

private func validMovesForKing(_ color: String, at position: String, in gameState: GameState) -> [String] {
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

    // King moves one tile in all directions: up, down, left, right, up left, up right, down left, down right, up diagonal left, up diagonal right, down diagonal left, and down diagonal right (12 total directions)

    // Move up
    if isValidPosition(columnToCheck: colIndex, rowToCheck: rowIndex + 1, in: gameState) {
        if gameState.board[colIndex][rowIndex + 1] == nil || gameState.board[colIndex][rowIndex + 1]?.color != color {
            validBoardMoves.append((colIndex, rowIndex + 1))
        }
    }

    // Move down
    if isValidPosition(columnToCheck: colIndex, rowToCheck: rowIndex - 1, in: gameState) {
        if gameState.board[colIndex][rowIndex - 1] == nil || gameState.board[colIndex][rowIndex - 1]?.color != color {
            validBoardMoves.append((colIndex, rowIndex - 1))
        }
    }

    // Move left
    if colIndex - 2 > 4 && isValidPosition(columnToCheck: colIndex - 2, rowToCheck: rowIndex + 1, in: gameState) {//on the right of the board
        if gameState.board[colIndex - 2][rowIndex + 1] == nil || gameState.board[colIndex - 2][rowIndex + 1]?.color != color {
            validBoardMoves.append((colIndex - 2, rowIndex + 1))
        }
    } else if colIndex - 2 == 4 && isValidPosition(columnToCheck: colIndex - 2, rowToCheck: rowIndex, in: gameState) {//crossing the midde column
        if gameState.board[colIndex - 2][rowIndex] == nil || gameState.board[colIndex - 2][rowIndex]?.color != color {
            validBoardMoves.append((colIndex - 2, rowIndex))
        }
    } else if colIndex - 2 < 4 && isValidPosition(columnToCheck: colIndex - 2, rowToCheck: rowIndex - 1, in: gameState) {// on the left of the board
        if gameState.board[colIndex - 2][rowIndex - 1] == nil || gameState.board[colIndex - 2][rowIndex - 1]?.color != color {
            validBoardMoves.append((colIndex - 2, rowIndex - 1))
        }
    }

    // Move right
    if colIndex + 2 < 6 && isValidPosition(columnToCheck: colIndex + 2, rowToCheck: rowIndex + 1, in: gameState) {//on the left of the board
        if gameState.board[colIndex + 2][rowIndex + 1] == nil || gameState.board[colIndex + 2][rowIndex + 1]?.color != color {
            validBoardMoves.append((colIndex + 2, rowIndex + 1))
        }
    } else if colIndex + 2 == 6 && isValidPosition(columnToCheck: colIndex + 2, rowToCheck: rowIndex, in: gameState) {//crossing the middle column
        if gameState.board[colIndex + 2][rowIndex] == nil || gameState.board[colIndex + 2][rowIndex]?.color != color {
            validBoardMoves.append((colIndex + 2, rowIndex))
        }
    } else if colIndex + 2 > 6 && isValidPosition(columnToCheck: colIndex + 2, rowToCheck: rowIndex - 1, in: gameState) {//on the right of the board
        if gameState.board[colIndex + 2][rowIndex - 1] == nil || gameState.board[colIndex + 2][rowIndex - 1]?.color != color {
            validBoardMoves.append((colIndex + 2, rowIndex - 1))
        }
    }

    // Move up left
    if colIndex - 1 >= 5 && isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex + 1, in: gameState) {//on the right of the board
        if gameState.board[colIndex - 1][rowIndex + 1] == nil || gameState.board[colIndex - 1][rowIndex + 1]?.color != color {
            validBoardMoves.append((colIndex - 1, rowIndex + 1))
        }
    } else if colIndex - 1 < 5 && isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex, in: gameState) {//on the middle/left of the board
        if gameState.board[colIndex - 1][rowIndex] == nil || gameState.board[colIndex - 1][rowIndex]?.color != color {
            validBoardMoves.append((colIndex - 1, rowIndex))
        }
    }

    // Move up right
    if colIndex + 1 <= 5 && isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex + 1, in: gameState) {//on the left of the board
        if gameState.board[colIndex + 1][rowIndex + 1] == nil || gameState.board[colIndex + 1][rowIndex + 1]?.color != color {
            validBoardMoves.append((colIndex + 1, rowIndex + 1))
        }
    } else if colIndex + 1 > 5 && isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex, in: gameState) {//on right middle/right of the board
        if gameState.board[colIndex + 1][rowIndex] == nil || gameState.board[colIndex + 1][rowIndex]?.color != color {
            validBoardMoves.append((colIndex + 1, rowIndex))
        }
    }

    // Move down left
    if colIndex - 1 >= 5 && isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex, in: gameState) {//on the right of the board
        if gameState.board[colIndex - 1][rowIndex] == nil || gameState.board[colIndex - 1][rowIndex]?.color != color {
            validBoardMoves.append((colIndex - 1, rowIndex))
        }
    } else if colIndex - 1 < 5 && isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex - 1, in: gameState) {// on the middle/left of the board
        if gameState.board[colIndex - 1][rowIndex - 1] == nil || gameState.board[colIndex - 1][rowIndex - 1]?.color != color {
            validBoardMoves.append((colIndex - 1, rowIndex - 1))
        }
    }

    // Move down right
    if colIndex + 1 <= 5 && isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex, in: gameState) {//on the left of the board
        if gameState.board[colIndex + 1][rowIndex] == nil || gameState.board[colIndex + 1][rowIndex]?.color != color {
            validBoardMoves.append((colIndex + 1, rowIndex))
        }
    } else if colIndex + 1 > 5 && isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex - 1, in: gameState) {//on the middle/right of the board
        if gameState.board[colIndex + 1][rowIndex - 1] == nil || gameState.board[colIndex + 1][rowIndex - 1]?.color != color {
            validBoardMoves.append((colIndex + 1, rowIndex - 1))
        }
    }
    
    // Move up left diagonal
    if colIndex - 1 >= 5 && isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex + 2, in: gameState) {//on the right of the board
        if gameState.board[colIndex - 1][rowIndex + 2] == nil || gameState.board[colIndex - 1][rowIndex + 2]?.color != color {
            validBoardMoves.append((colIndex - 1, rowIndex + 2))
        }
    } else if colIndex - 1 < 5 && isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex + 1, in: gameState) {//on the middle/left of the board
        if gameState.board[colIndex - 1][rowIndex + 1] == nil || gameState.board[colIndex - 1][rowIndex + 1]?.color != color {
            validBoardMoves.append((colIndex - 1, rowIndex + 1))
        }
    }
    
    // Move up right diagonal
    if colIndex + 1 <= 5 && isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex + 2, in: gameState) {//on the left of the board
        if gameState.board[colIndex + 1][rowIndex + 2] == nil || gameState.board[colIndex + 1][rowIndex + 2]?.color != color {
            validBoardMoves.append((colIndex + 1, rowIndex + 2))
        }
    } else if colIndex + 1 > 5 && isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex + 1, in: gameState) {//on the middle/right of the board
        if gameState.board[colIndex + 1][rowIndex + 1] == nil || gameState.board[colIndex + 1][rowIndex + 1]?.color != color {
            validBoardMoves.append((colIndex + 1, rowIndex + 1))
        }
    }
    
    // Move down left diagonal
    if colIndex - 1 >= 5 && isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex - 1, in: gameState) {//on the right of the board
        if gameState.board[colIndex - 1][rowIndex - 1] == nil || gameState.board[colIndex - 1][rowIndex - 1]?.color != color {
            validBoardMoves.append((colIndex - 1, rowIndex - 1))
        }
    } else if colIndex - 1 < 5 && isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex - 2, in: gameState) {//on the middle/left of the board
        if gameState.board[colIndex - 1][rowIndex - 2] == nil || gameState.board[colIndex - 1][rowIndex - 2]?.color != color {
            validBoardMoves.append((colIndex - 1, rowIndex - 2))
        }
    }
    
    // Move down right diagonal
    if colIndex + 1 <= 5 && isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex - 1, in: gameState) {//on the left of the board
        if gameState.board[colIndex + 1][rowIndex - 1] == nil || gameState.board[colIndex + 1][rowIndex - 1]?.color != color {
            validBoardMoves.append((colIndex + 1, rowIndex - 1))
        }
    } else if colIndex + 1 > 5 && isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex - 2, in: gameState) {//on the middle/right of the board
        if gameState.board[colIndex + 1][rowIndex - 2] == nil || gameState.board[colIndex + 1][rowIndex - 2]?.color != color {
            validBoardMoves.append((colIndex + 1, rowIndex - 2))
        }
    }
    
    return boardToHex(validBoardMoves)
}
