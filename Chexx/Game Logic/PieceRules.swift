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

func validMovesForPiece(at position: String, color: String, type: String, in gameState: inout GameState, skipKingCheck: Bool = false) -> [String] {
    var possibleMoves: [String] = []

    switch type {
    case "pawn":
        possibleMoves = validMovesForPawn(color, at: position, in: gameState)
    case "rook":
        possibleMoves = validMovesForRook(color, at: position, in: gameState)
    case "bishop":
        possibleMoves = validMovesForBishop(color, at: position, in: gameState)
    case "queen":
        let rookMoves = validMovesForRook(color, at: position, in: gameState)
        let bishopMoves = validMovesForBishop(color, at: position, in: gameState)
        possibleMoves = Array(Set(rookMoves + bishopMoves))
    case "king":
        possibleMoves = validMovesForKing(color, at: position, in: gameState)
    case "knight":
        possibleMoves = validMovesForKnight(color, at: position, in: gameState)
    default:
        possibleMoves = []
    }

    if skipKingCheck { //this adds overhead (albiet very little) for one silly achievement (hextreme_measures). there might be a better way, but it also might not be worth it
        return possibleMoves // check up on this ^ (is skipKingCheck still needed?)
    } else { //normally this executes
        return filterMovesThatExposeKing(possibleMoves, for: color, at: position, in: &gameState)
    }
}

func validMovesForPawn(_ color: String, at position: String, in gameState: GameState) -> [String] {
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
           gameState.board[colIndex][rowIndex + 1] == nil { //cannot capture straight, needs to be empty
            validBoardMoves.append((colIndex, rowIndex + 1))

            // If it hasn't moved at all, bonus move!
            if !gameState.board[colIndex][rowIndex]!.hasMoved,
               gameState.board[colIndex][rowIndex + 2] == nil {
                validBoardMoves.append((colIndex, rowIndex + 2)) // opening bonus 2 tiles!
            }
        }
        // Capture logic for left and right
        if colIndex < 5 { // Left side of board
            //left on left
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex, in: gameState),
               gameState.board[colIndex - 1][rowIndex]?.color == "black" {
                validBoardMoves.append((colIndex - 1, rowIndex))
            }
            //right on left
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex + 1, in: gameState),
               gameState.board[colIndex + 1][rowIndex + 1]?.color == "black" {
                validBoardMoves.append((colIndex + 1, rowIndex + 1))
            }
            //en passant left on left
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex - 1, in: gameState),
               gameState.board[colIndex - 1][rowIndex - 1]?.color == "black" 
                && gameState.board[colIndex - 1][rowIndex - 1]?.isEnPassantTarget == true {
                validBoardMoves.append((colIndex - 1, rowIndex)) //looking below, capturing above
            }
            //en passant right on left
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex, in: gameState),
               gameState.board[colIndex + 1][rowIndex]?.color == "black"
                && gameState.board[colIndex + 1][rowIndex]?.isEnPassantTarget == true {
                validBoardMoves.append((colIndex + 1, rowIndex + 1))//looking below, capturing above
            }
        } else if colIndex == 5 { // Center of board
            //left on center
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex, in: gameState),
               gameState.board[colIndex - 1][rowIndex]?.color == "black" {
                validBoardMoves.append((colIndex - 1, rowIndex))
            }
            //right on center
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex, in: gameState),
               gameState.board[colIndex + 1][rowIndex]?.color == "black" {
                validBoardMoves.append((colIndex + 1, rowIndex))
            }
            //en passant left on center
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex - 1, in: gameState),
               gameState.board[colIndex - 1][rowIndex - 1]?.color == "black"
                && gameState.board[colIndex - 1][rowIndex - 1]?.isEnPassantTarget == true {
                validBoardMoves.append((colIndex - 1, rowIndex))
            }
            //en passant right on center
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex - 1, in: gameState),
               gameState.board[colIndex + 1][rowIndex - 1]?.color == "black" 
                && gameState.board[colIndex + 1][rowIndex - 1]?.isEnPassantTarget == true {
                validBoardMoves.append((colIndex + 1, rowIndex))
            }
        } else { // Right side of board
            //left on right
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex + 1, in: gameState),
               gameState.board[colIndex - 1][rowIndex + 1]?.color == "black" {
                validBoardMoves.append((colIndex - 1, rowIndex + 1))
            }
            //right on right
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex, in: gameState),
               gameState.board[colIndex + 1][rowIndex]?.color == "black" {
                validBoardMoves.append((colIndex + 1, rowIndex))
            }
            //en passant left on right
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex, in: gameState),
               gameState.board[colIndex - 1][rowIndex]?.color == "black" 
                && gameState.board[colIndex - 1][rowIndex]?.isEnPassantTarget == true {
                validBoardMoves.append((colIndex - 1, rowIndex + 1))
            }
            //en passant right on right
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex - 1, in: gameState),
               gameState.board[colIndex + 1][rowIndex - 1]?.color == "black" 
                && gameState.board[colIndex + 1][rowIndex - 1]?.isEnPassantTarget == true {
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
            //left on left
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex - 1, in: gameState),
               gameState.board[colIndex - 1][rowIndex - 1]?.color == "white" {
                validBoardMoves.append((colIndex - 1, rowIndex - 1))
            }
            //right on left
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex, in: gameState),
               gameState.board[colIndex + 1][rowIndex]?.color == "white" {
                validBoardMoves.append((colIndex + 1, rowIndex))
            }
            //en passant left on left
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex, in: gameState),
               gameState.board[colIndex - 1][rowIndex]?.color == "white" 
                && gameState.board[colIndex - 1][rowIndex]?.isEnPassantTarget == true {
                validBoardMoves.append((colIndex - 1, rowIndex - 1))
            }
            //en passant right on left
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex + 1, in: gameState),
               gameState.board[colIndex + 1][rowIndex + 1]?.color == "white"
                && gameState.board[colIndex + 1][rowIndex + 1]?.isEnPassantTarget == true {
                validBoardMoves.append((colIndex + 1, rowIndex))
            }
        } else if colIndex == 5 { // Center of board
            //left on center
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex - 1, in: gameState),
               gameState.board[colIndex - 1][rowIndex - 1]?.color == "white" {
                validBoardMoves.append((colIndex - 1, rowIndex - 1))
            }
            //right on center
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex - 1, in: gameState),
               gameState.board[colIndex + 1][rowIndex - 1]?.color == "white" {
                validBoardMoves.append((colIndex + 1, rowIndex - 1))
            }
            //en passant left on center
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex, in: gameState),
               gameState.board[colIndex - 1][rowIndex]?.color == "white" 
                && gameState.board[colIndex - 1][rowIndex]?.isEnPassantTarget == true {
                validBoardMoves.append((colIndex - 1, rowIndex - 1))
            }
            //en passant right on center
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex, in: gameState),
               gameState.board[colIndex + 1][rowIndex]?.color == "white"
                && gameState.board[colIndex + 1][rowIndex]?.isEnPassantTarget == true {
                validBoardMoves.append((colIndex + 1, rowIndex - 1))
            }
        } else { // Right side of board
            //left on right
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex, in: gameState),
               gameState.board[colIndex - 1][rowIndex]?.color == "white" {
                validBoardMoves.append((colIndex - 1, rowIndex))
            }
            //right on right
            if colIndex + 1 < columns.count,
               isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex - 1, in: gameState),
               gameState.board[colIndex + 1][rowIndex - 1]?.color == "white" {
                validBoardMoves.append((colIndex + 1, rowIndex - 1))
            }
            //en passant left on right
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex + 1, in: gameState),
               gameState.board[colIndex - 1][rowIndex + 1]?.color == "white" 
                && gameState.board[colIndex - 1][rowIndex + 1]?.isEnPassantTarget == true  {
                validBoardMoves.append((colIndex - 1, rowIndex))
            }
            //en passant right on right
            if colIndex + 1 < columns.count,
               isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex, in: gameState),
               gameState.board[colIndex + 1][rowIndex]?.color == "white" 
                && gameState.board[colIndex + 1][rowIndex]?.isEnPassantTarget == true  {
                validBoardMoves.append((colIndex + 1, rowIndex - 1))
            }
        }
    }
    return boardToHex(validBoardMoves)
}

func validMovesForRook(_ color: String, at position: String, in gameState: GameState) -> [String] {
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

func validMovesForBishop(_ color: String, at position: String, in gameState: GameState) -> [String] {
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
    var downCounter = 1
    
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
    downCounter = 1
    
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
        while colIndex - counter < 5 && isValidPosition(columnToCheck: colIndex - counter, rowToCheck: new_starting_row - (downCounter * 2), in: gameState) {
            if gameState.board[colIndex - counter][new_starting_row - (downCounter * 2)] == nil {
                validBoardMoves.append((colIndex - counter, new_starting_row - (downCounter * 2)))
            } else if gameState.board[colIndex - counter][new_starting_row - (downCounter * 2)]?.color == color {
                break
            } else {
                validBoardMoves.append((colIndex - counter, new_starting_row - (downCounter * 2)))
                break
            }
            counter += 1
            downCounter += 1
        }
    
    // Move down right diagonal...
    counter = 1
    downCounter = 1
    
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
        while colIndex + counter > 5 && isValidPosition(columnToCheck: colIndex + counter, rowToCheck: new_starting_row - (downCounter * 2), in: gameState) {
            if gameState.board[colIndex + counter][new_starting_row - (downCounter * 2)] == nil {
                validBoardMoves.append((colIndex + counter, new_starting_row - (downCounter * 2)))
            } else if gameState.board[colIndex + counter][new_starting_row - (downCounter * 2)]?.color == color {
                break
            } else {
                validBoardMoves.append((colIndex + counter, new_starting_row - (downCounter * 2)))
                break
            }
            counter += 1
            downCounter += 1
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

func validMovesForKing(_ color: String, at position: String, in gameState: GameState) -> [String] {
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

func validMovesForKnight(_ color: String, at position: String, in gameState: GameState) -> [String] {
    let columns = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "k", "l"]
    var validBoardMoves: [(Int, Int)] = []

    guard position.count >= 2,
          let columnLetter = position.first,
          var rowIndex = Int(String(position.dropFirst())),
          let colIndex = columns.firstIndex(of: String(columnLetter)) else {
        print("Position only has string length of 1!")
        return boardToHex(validBoardMoves)
    }
    rowIndex = rowIndex - 1 // making it 0 indexed

    func tryAddMove(col: Int, row: Int) {
        if isValidPosition(columnToCheck: col, rowToCheck: row, in: gameState),
           gameState.board[col][row] == nil || gameState.board[col][row]?.color != color {
            validBoardMoves.append((col, row))
        }
    }
    
    //this is the most complicated piece, a diagram of knight movement can be found at:
    //https://en.wikipedia.org/wiki/File:Glinski_Chess_Knight.svg

    // Move UP 2, UPPER LEFT 1...
    if colIndex > 5 {
        tryAddMove(col: colIndex - 1, row: rowIndex + 3)
    }
    if colIndex <= 5 {
        tryAddMove(col: colIndex - 1, row: rowIndex + 2)
    }

    // Move UP 2, UPPER RIGHT 1
    if colIndex >= 5 {
        tryAddMove(col: colIndex + 1, row: rowIndex + 2)
    }
    if colIndex < 5 {
        tryAddMove(col: colIndex + 1, row: rowIndex + 3)
    }

    // UPPER LEFT 2, UP 1
    if colIndex <= 5 {
        tryAddMove(col: colIndex - 2, row: rowIndex + 1)
    }
    if colIndex == 6 {
        tryAddMove(col: colIndex - 2, row: rowIndex + 2)
    }
    if colIndex >= 7 {
        tryAddMove(col: colIndex - 2, row: rowIndex + 3)
    }

    // UPPER RIGHT 2, UP 1
    if colIndex >= 5 {
        tryAddMove(col: colIndex + 2, row: rowIndex + 1)
    }
    if colIndex == 4 {
        tryAddMove(col: colIndex + 2, row: rowIndex + 2)
    }
    if colIndex <= 3 {
        tryAddMove(col: colIndex + 2, row: rowIndex + 3)
    }

    // UPPER LEFT 2, BOTTOM LEFT 1
    if colIndex <= 5 {
        tryAddMove(col: colIndex - 3, row: rowIndex - 1)
    }
    if colIndex == 6 {
        tryAddMove(col: colIndex - 3, row: rowIndex)
    }
    if colIndex == 7 {
        tryAddMove(col: colIndex - 3, row: rowIndex + 1)
    }
    if colIndex >= 8 {
        tryAddMove(col: colIndex - 3, row: rowIndex + 2)
    }

    // UPPER RIGHT 2, BOTTOM RIGHT 1
    if colIndex >= 5 {
        tryAddMove(col: colIndex + 3, row: rowIndex - 1)
    }
    if colIndex == 4 {
        tryAddMove(col: colIndex + 3, row: rowIndex)
    }
    if colIndex == 3 {
        tryAddMove(col: colIndex + 3, row: rowIndex + 1)
    }
    if colIndex <= 2 {
        tryAddMove(col: colIndex + 3, row: rowIndex + 2)
    }

    // LOWER LEFT 2, UPPER LEFT 1
    if colIndex <= 5 {
        tryAddMove(col: colIndex - 3, row: rowIndex - 2)
    }
    if colIndex == 6 {
        tryAddMove(col: colIndex - 3, row: rowIndex - 1)
    }
    if colIndex == 7 {
        tryAddMove(col: colIndex - 3, row: rowIndex)
    }
    if colIndex >= 8 {
        tryAddMove(col: colIndex - 3, row: rowIndex + 1)
    }

    // LOWER RIGHT 2, UPPER RIGHT 1
    if colIndex >= 5 {
        tryAddMove(col: colIndex + 3, row: rowIndex - 2)
    }
    if colIndex == 4 {
        tryAddMove(col: colIndex + 3, row: rowIndex - 1)
    }
    if colIndex == 3 {
        tryAddMove(col: colIndex + 3, row: rowIndex)
    }
    if colIndex <= 2 {
        tryAddMove(col: colIndex + 3, row: rowIndex + 1)
    }

    // LOWER LEFT 2, DOWN 1
    if colIndex <= 5 {
        tryAddMove(col: colIndex - 2, row: rowIndex - 3)
    }
    if colIndex == 6 {
        tryAddMove(col: colIndex - 2, row: rowIndex - 2)
    }
    if colIndex >= 7 {
        tryAddMove(col: colIndex - 2, row: rowIndex - 1)
    }

    // LOWER RIGHT 2, DOWN 1
    if colIndex >= 5 {
        tryAddMove(col: colIndex + 2, row: rowIndex - 3)
    }
    if colIndex == 4 {
        tryAddMove(col: colIndex + 2, row: rowIndex - 2)
    }
    if colIndex <= 3 {
        tryAddMove(col: colIndex + 2, row: rowIndex - 1)
    }

    // DOWN 2, BOTTOM LEFT 1
    if colIndex > 5 {
        tryAddMove(col: colIndex - 1, row: rowIndex - 2)
    }
    if colIndex <= 5 {
        tryAddMove(col: colIndex - 1, row: rowIndex - 3)
    }

    // DOWN 2, LOWER RIGHT 1
    if colIndex >= 5 {
        tryAddMove(col: colIndex + 1, row: rowIndex - 3)
    }
    if colIndex < 5 {
        tryAddMove(col: colIndex + 1, row: rowIndex - 2)
    }

    return boardToHex(validBoardMoves)
}


private func filterMovesThatExposeKing(_ moves: [String], for color: String, at position: String, in gameState: inout GameState) -> [String] {
    //print("moves", moves, "for", color, "position", position)
    return moves.filter { move in

        let undoInfo = gameState.makeMove(position, to: move)

        let kingInCheck = isKingInCheckUsingKingSight(for: color, in: &gameState) //can swap out this function for the commented out one, the commented out one fs works but is slow

        gameState.unmakeMove(position, to: move, undoInfo: undoInfo)
        
        return !kingInCheck.0
    }
}

func isKingInCheckUsingKingSight(for color: String, in currentGameState: inout GameState) -> (Bool, String) {
    let kingPosition: String
    if color == "white" {
        kingPosition = currentGameState.whiteKingPosition
    } else {
        kingPosition = currentGameState.blackKingPosition
    }

    let opponentColor = color == "white" ? "black" : "white"

    // Rook and Queen threats (straight-line moves)
    let rookMoves = validMovesForRook(color, at: kingPosition, in: currentGameState)
    for position in rookMoves {
        if let piece = currentGameState.pieceAt(position),
           piece.color == opponentColor,
           (piece.type == "rook" || piece.type == "queen") {
            return (true, ("\(position) \(piece.color) \(piece.type)"))
        }
    }

    // Bishop and Queen threats (diagonal moves)
    let bishopMoves = validMovesForBishop(color, at: kingPosition, in: currentGameState)
    for position in bishopMoves {
        if let piece = currentGameState.pieceAt(position),
           piece.color == opponentColor,
           (piece.type == "bishop" || piece.type == "queen") {
            return (true, ("\(position) \(piece.color) \(piece.type)"))
        }
    }

    // Knight threats (L-shaped moves)
    let knightMoves = validMovesForKnight(color, at: kingPosition, in: currentGameState)
    for position in knightMoves {
        if let piece = currentGameState.pieceAt(position),
           piece.color == opponentColor,
           piece.type == "knight" {
            return (true, ("\(position) \(piece.color) \(piece.type)"))
        }
    }
    
    // Opposing king potential threats (should never happen, this is so they are avoided)
    let kingMoves = validMovesForKing(color, at: kingPosition, in: currentGameState)
    for position in kingMoves {
        if let piece = currentGameState.pieceAt(position),
           piece.color == opponentColor,
           piece.type == "king" {
            return (true, ("\(position) \(piece.color) \(piece.type)"))
        }
    }

    // Pawn threats (single step diagonal moves towards the king)
    let pawnMoves = pawnPureCaptures(color, at: kingPosition, in: currentGameState)
    for position in pawnMoves { //this is also checking straight ahead, wrong //fix this later
        if let piece = currentGameState.pieceAt(position),
           piece.color == opponentColor,
           piece.type == "pawn" {
            return (true, ("\(position) \(piece.color) \(piece.type)"))
        }
    }

    return (false, "none") // No threats detected
}

func pawnPureCaptures(_ color: String, at position: String, in gameState: GameState) -> [String] {
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

    if color == "white" {
        // Capture logic for left and right
        if colIndex < 5 { // Left side of board
            //left on left
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex, in: gameState),
               gameState.board[colIndex - 1][rowIndex]?.color == "black" {
                validBoardMoves.append((colIndex - 1, rowIndex))
            }
            //right on left
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex + 1, in: gameState),
               gameState.board[colIndex + 1][rowIndex + 1]?.color == "black" {
                validBoardMoves.append((colIndex + 1, rowIndex + 1))
            }
        } else if colIndex == 5 { // Center of board
            //left on center
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex, in: gameState),
               gameState.board[colIndex - 1][rowIndex]?.color == "black" {
                validBoardMoves.append((colIndex - 1, rowIndex))
            }
            //right on center
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex, in: gameState),
               gameState.board[colIndex + 1][rowIndex]?.color == "black" {
                validBoardMoves.append((colIndex + 1, rowIndex))
            }
        } else { // Right side of board
            //left on right
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex + 1, in: gameState),
               gameState.board[colIndex - 1][rowIndex + 1]?.color == "black" {
                validBoardMoves.append((colIndex - 1, rowIndex + 1))
            }
            //right on right
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex, in: gameState),
               gameState.board[colIndex + 1][rowIndex]?.color == "black" {
                validBoardMoves.append((colIndex + 1, rowIndex))
            }
        }
    }

    if color == "black" {
        // Capture logic for left and right
        if colIndex < 5 { // Left side of board
            //left on left
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex - 1, in: gameState),
               gameState.board[colIndex - 1][rowIndex - 1]?.color == "white" {
                validBoardMoves.append((colIndex - 1, rowIndex - 1))
            }
            //right on left
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex, in: gameState),
               gameState.board[colIndex + 1][rowIndex]?.color == "white" {
                validBoardMoves.append((colIndex + 1, rowIndex))
            }
        } else if colIndex == 5 { // Center of board
            //left on center
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex - 1, in: gameState),
               gameState.board[colIndex - 1][rowIndex - 1]?.color == "white" {
                validBoardMoves.append((colIndex - 1, rowIndex - 1))
            }
            //right on center
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex - 1, in: gameState),
               gameState.board[colIndex + 1][rowIndex - 1]?.color == "white" {
                validBoardMoves.append((colIndex + 1, rowIndex - 1))
            }
        } else { // Right side of board
            //left on right
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex, in: gameState),
               gameState.board[colIndex - 1][rowIndex]?.color == "white" {
                validBoardMoves.append((colIndex - 1, rowIndex))
            }
            //right on right
            if colIndex + 1 < columns.count,
               isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex - 1, in: gameState),
               gameState.board[colIndex + 1][rowIndex - 1]?.color == "white" {
                validBoardMoves.append((colIndex + 1, rowIndex - 1))
            }
        }
    }
    return boardToHex(validBoardMoves)

}

/*
func isKingInCheck(for color: String, in currentGameState: inout GameState) -> Bool {
    let kingPosition: String
    
    if color == "white" {
        kingPosition = currentGameState.whiteKingPosition
    } else {
        kingPosition = currentGameState.blackKingPosition
    }
    //print(kingPosition)
    
    //print("generating all opponent moves...")
    let opponentColor = color == "white" ? "black" : "white"
    let opponentMoves = generateAllMoves(for: opponentColor, in: &currentGameState)
    
    return opponentMoves.contains(kingPosition)
}

func generateAllMoves(for color: String, in gameState: inout GameState) -> [String] {
    let columns = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "k", "l"]
    var allMoves: [String] = []

    for (colIndex, column) in gameState.board.enumerated() {
        for (rowIndex, piece) in column.enumerated() {
            if let piece = piece, piece.color == color {
                let currentPosition = "\(columns[colIndex])\(rowIndex + 1)"
                let validMoves = validMovesForPiece(at: currentPosition, color: piece.color, type: piece.type, in: &gameState, skipKingCheck: true)
                allMoves.append(contentsOf: validMoves)
            }
        }
    }

    return allMoves
}*/
