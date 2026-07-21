//
//  PieceRules.swift
//  Chexx
//
//  Created by Sawyer Christensen on 7/4/24.
//

import Foundation
import SpriteKit

let hexColumns = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "k", "l"]

// O(1) column-letter lookup, replacing `hexColumns.firstIndex(of: String(letter))` linear scans
// (which also allocated a throwaway single-character String on every call) throughout the
// move-generation/search hot path.
func hexColumnIndex(for letter: Character) -> Int? {
    switch letter {
    case "a": return 0
    case "b": return 1
    case "c": return 2
    case "d": return 3
    case "e": return 4
    case "f": return 5
    case "g": return 6
    case "h": return 7
    case "i": return 8
    case "k": return 9
    case "l": return 10
    default: return nil
    }
}

func hexColumnIndex(for letter: some StringProtocol) -> Int? {
    guard letter.count == 1, let char = letter.first else { return nil }
    return hexColumnIndex(for: char)
}

func isValidPosition(columnToCheck: Int, rowToCheck: Int, in gameState: GameState) -> Bool {
    return columnToCheck >= 0 &&
    columnToCheck <= 10 &&
    rowToCheck >= 0 &&
    rowToCheck < gameState.rowCount(forCol: columnToCheck)
}

func boardToHex(_ positions: [(Int, Int)]) -> [String] {
    let columns = hexColumns
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

// Parses algebraic notation (e.g. "a1") into a 0-indexed (col, row) tuple matching gameState.board,
// shared by the validMovesFor*(String) wrappers so each one does exactly one parse at its boundary.
private func parsePosition(_ position: String) -> (col: Int, row: Int)? {
    guard position.count >= 2,
          let columnLetter = position.first,
          let rowValue = Int(String(position.dropFirst())),
          let colIndex = hexColumnIndex(for: columnLetter) else {
        return nil
    }
    return (colIndex, rowValue - 1)
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
    guard let (colIndex, rowIndex) = parsePosition(position) else {
        print("Position only has string length of 1!")
        return []
    }
    return boardToHex(validMovesForPawn(color, at: (colIndex, rowIndex), in: gameState))
}

func validMovesForPawn(_ color: String, at position: (Int, Int), in gameState: GameState) -> [(Int, Int)] {
    let columns = hexColumns
    var validBoardMoves: [(Int, Int)] = []
    let (colIndex, rowIndex) = position

    if color == "white" {
        // Move up 1
        if isValidPosition(columnToCheck: colIndex, rowToCheck: rowIndex + 1, in: gameState),
           gameState[colIndex, rowIndex + 1] == nil { //cannot capture straight, needs to be empty
            validBoardMoves.append((colIndex, rowIndex + 1))

            // If it hasn't moved at all, bonus move!
            if gameState[colIndex, rowIndex]?.hasMoved == false,
               gameState[colIndex, rowIndex + 2] == nil {
                validBoardMoves.append((colIndex, rowIndex + 2)) // opening bonus 2 tiles!
            }
        }
        // Capture logic for left and right
        if colIndex < 5 { // Left side of board
            //left on left
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex, in: gameState),
               gameState[colIndex - 1, rowIndex]?.color == "black" {
                validBoardMoves.append((colIndex - 1, rowIndex))
            }
            //right on left
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex + 1, in: gameState),
               gameState[colIndex + 1, rowIndex + 1]?.color == "black" {
                validBoardMoves.append((colIndex + 1, rowIndex + 1))
            }
            //en passant left on left
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex - 1, in: gameState),
               gameState[colIndex - 1, rowIndex - 1]?.color == "black" 
                && gameState[colIndex - 1, rowIndex - 1]?.isEnPassantTarget == true {
                validBoardMoves.append((colIndex - 1, rowIndex)) //looking below, capturing above
            }
            //en passant right on left
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex, in: gameState),
               gameState[colIndex + 1, rowIndex]?.color == "black"
                && gameState[colIndex + 1, rowIndex]?.isEnPassantTarget == true {
                validBoardMoves.append((colIndex + 1, rowIndex + 1))//looking below, capturing above
            }
        } else if colIndex == 5 { // Center of board
            //left on center
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex, in: gameState),
               gameState[colIndex - 1, rowIndex]?.color == "black" {
                validBoardMoves.append((colIndex - 1, rowIndex))
            }
            //right on center
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex, in: gameState),
               gameState[colIndex + 1, rowIndex]?.color == "black" {
                validBoardMoves.append((colIndex + 1, rowIndex))
            }
            //en passant left on center
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex - 1, in: gameState),
               gameState[colIndex - 1, rowIndex - 1]?.color == "black"
                && gameState[colIndex - 1, rowIndex - 1]?.isEnPassantTarget == true {
                validBoardMoves.append((colIndex - 1, rowIndex))
            }
            //en passant right on center
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex - 1, in: gameState),
               gameState[colIndex + 1, rowIndex - 1]?.color == "black" 
                && gameState[colIndex + 1, rowIndex - 1]?.isEnPassantTarget == true {
                validBoardMoves.append((colIndex + 1, rowIndex))
            }
        } else { // Right side of board
            //left on right
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex + 1, in: gameState),
               gameState[colIndex - 1, rowIndex + 1]?.color == "black" {
                validBoardMoves.append((colIndex - 1, rowIndex + 1))
            }
            //right on right
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex, in: gameState),
               gameState[colIndex + 1, rowIndex]?.color == "black" {
                validBoardMoves.append((colIndex + 1, rowIndex))
            }
            //en passant left on right
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex, in: gameState),
               gameState[colIndex - 1, rowIndex]?.color == "black" 
                && gameState[colIndex - 1, rowIndex]?.isEnPassantTarget == true {
                validBoardMoves.append((colIndex - 1, rowIndex + 1))
            }
            //en passant right on right
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex - 1, in: gameState),
               gameState[colIndex + 1, rowIndex - 1]?.color == "black" 
                && gameState[colIndex + 1, rowIndex - 1]?.isEnPassantTarget == true {
                validBoardMoves.append((colIndex + 1, rowIndex))
            }
        }
    }

    if color == "black" {
        // Move down 1
        if isValidPosition(columnToCheck: colIndex, rowToCheck: rowIndex - 1, in: gameState),
           gameState[colIndex, rowIndex - 1] == nil {
            validBoardMoves.append((colIndex, rowIndex - 1))

            // If it hasn't moved at all, bonus move!
            if gameState[colIndex, rowIndex]?.hasMoved == false,
               gameState[colIndex, rowIndex - 2] == nil {
                validBoardMoves.append((colIndex, rowIndex - 2)) // opening bonus 2 tiles!
            }
        }
        // Capture logic for left and right
        if colIndex < 5 { // Left side of board
            //left on left
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex - 1, in: gameState),
               gameState[colIndex - 1, rowIndex - 1]?.color == "white" {
                validBoardMoves.append((colIndex - 1, rowIndex - 1))
            }
            //right on left
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex, in: gameState),
               gameState[colIndex + 1, rowIndex]?.color == "white" {
                validBoardMoves.append((colIndex + 1, rowIndex))
            }
            //en passant left on left
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex, in: gameState),
               gameState[colIndex - 1, rowIndex]?.color == "white" 
                && gameState[colIndex - 1, rowIndex]?.isEnPassantTarget == true {
                validBoardMoves.append((colIndex - 1, rowIndex - 1))
            }
            //en passant right on left
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex + 1, in: gameState),
               gameState[colIndex + 1, rowIndex + 1]?.color == "white"
                && gameState[colIndex + 1, rowIndex + 1]?.isEnPassantTarget == true {
                validBoardMoves.append((colIndex + 1, rowIndex))
            }
        } else if colIndex == 5 { // Center of board
            //left on center
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex - 1, in: gameState),
               gameState[colIndex - 1, rowIndex - 1]?.color == "white" {
                validBoardMoves.append((colIndex - 1, rowIndex - 1))
            }
            //right on center
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex - 1, in: gameState),
               gameState[colIndex + 1, rowIndex - 1]?.color == "white" {
                validBoardMoves.append((colIndex + 1, rowIndex - 1))
            }
            //en passant left on center
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex, in: gameState),
               gameState[colIndex - 1, rowIndex]?.color == "white" 
                && gameState[colIndex - 1, rowIndex]?.isEnPassantTarget == true {
                validBoardMoves.append((colIndex - 1, rowIndex - 1))
            }
            //en passant right on center
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex, in: gameState),
               gameState[colIndex + 1, rowIndex]?.color == "white"
                && gameState[colIndex + 1, rowIndex]?.isEnPassantTarget == true {
                validBoardMoves.append((colIndex + 1, rowIndex - 1))
            }
        } else { // Right side of board
            //left on right
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex, in: gameState),
               gameState[colIndex - 1, rowIndex]?.color == "white" {
                validBoardMoves.append((colIndex - 1, rowIndex))
            }
            //right on right
            if colIndex + 1 < columns.count,
               isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex - 1, in: gameState),
               gameState[colIndex + 1, rowIndex - 1]?.color == "white" {
                validBoardMoves.append((colIndex + 1, rowIndex - 1))
            }
            //en passant left on right
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex + 1, in: gameState),
               gameState[colIndex - 1, rowIndex + 1]?.color == "white" 
                && gameState[colIndex - 1, rowIndex + 1]?.isEnPassantTarget == true  {
                validBoardMoves.append((colIndex - 1, rowIndex))
            }
            //en passant right on right
            if colIndex + 1 < columns.count,
               isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex, in: gameState),
               gameState[colIndex + 1, rowIndex]?.color == "white" 
                && gameState[colIndex + 1, rowIndex]?.isEnPassantTarget == true  {
                validBoardMoves.append((colIndex + 1, rowIndex - 1))
            }
        }
    }
    return validBoardMoves
}

func validMovesForRook(_ color: String, at position: String, in gameState: GameState) -> [String] {
    guard let (colIndex, rowIndex) = parsePosition(position) else {
        print("Position only has string length of 1??")
        return []
    }
    return boardToHex(validMovesForRook(color, at: (colIndex, rowIndex), in: gameState))
}

func validMovesForRook(_ color: String, at position: (Int, Int), in gameState: GameState) -> [(Int, Int)] {
    var validBoardMoves: [(Int, Int)] = []
    let (colIndex, rowIndex) = position

    // Rook moves in four directions: up, down, left, right

    // Move up
    var counter = 1
    while isValidPosition(columnToCheck: colIndex, rowToCheck: rowIndex + counter, in: gameState) {
        if gameState[colIndex, rowIndex + counter] == nil {
            validBoardMoves.append((colIndex, rowIndex + counter))
        } else if gameState[colIndex, rowIndex + counter]?.color == color {
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
        if gameState[colIndex, rowIndex - counter] == nil {
            validBoardMoves.append((colIndex, rowIndex - counter))
        } else if gameState[colIndex, rowIndex - counter]?.color == color {
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
            if gameState[colIndex - counter, rowIndex + counter] == nil {
                validBoardMoves.append((colIndex - counter, rowIndex + counter))
            } else if gameState[colIndex - counter, rowIndex + counter]?.color == color {
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
            if gameState[colIndex - counter, new_starting_row] == nil {
                validBoardMoves.append((colIndex - counter, new_starting_row))
            } else if gameState[colIndex - counter, new_starting_row]?.color == color {
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
            if gameState[colIndex + counter, rowIndex + counter] == nil {
                validBoardMoves.append((colIndex + counter, rowIndex + counter))
            } else if gameState[colIndex + counter, rowIndex + counter]?.color == color {
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
            if gameState[colIndex + counter, new_starting_row] == nil {
                validBoardMoves.append((colIndex + counter, new_starting_row))
            } else if gameState[colIndex + counter, new_starting_row]?.color == color {
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
            if gameState[colIndex - counter, rowIndex] == nil {
                validBoardMoves.append((colIndex - counter, rowIndex))
            } else if gameState[colIndex - counter, rowIndex]?.color == color {
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
            if gameState[colIndex - counter, new_starting_row - counter] == nil {
                validBoardMoves.append((colIndex - counter, new_starting_row - counter))
            } else if gameState[colIndex - counter, new_starting_row - counter]?.color == color {
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
            if gameState[colIndex + counter, rowIndex] == nil {
                validBoardMoves.append((colIndex + counter, rowIndex))
            } else if gameState[colIndex + counter, rowIndex]?.color == color {
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
            if gameState[colIndex + counter, new_starting_row - counter] == nil {
                validBoardMoves.append((colIndex + counter, new_starting_row - counter))
            } else if gameState[colIndex + counter, new_starting_row - counter]?.color == color {
                break
            } else {
                validBoardMoves.append((colIndex + counter, new_starting_row - counter))
                break
            }
            counter += 1
        }

    return validBoardMoves
}

func validMovesForBishop(_ color: String, at position: String, in gameState: GameState) -> [String] {
    guard let (colIndex, rowIndex) = parsePosition(position) else {
        print("Position only has string length of 1!")
        return []
    }
    return boardToHex(validMovesForBishop(color, at: (colIndex, rowIndex), in: gameState))
}

func validMovesForBishop(_ color: String, at position: (Int, Int), in gameState: GameState) -> [(Int, Int)] {
    var validBoardMoves: [(Int, Int)] = []
    let (colIndex, rowIndex) = position

    // Bishop moves in six diagonal directions: up left, up right, down left, down right, perfect left, perfect right
    
    // Move up left diagonal...
    var counter = 1
    var downCounter = 1
    
        // ...on the right side of the board
        while colIndex - counter >= 5 && isValidPosition(columnToCheck: colIndex - counter, rowToCheck: rowIndex + (counter * 2), in: gameState) {
            if gameState[colIndex - counter, rowIndex + (counter * 2)] == nil {
                validBoardMoves.append((colIndex - counter, rowIndex + (counter * 2)))
            } else if gameState[colIndex - counter, rowIndex + (counter * 2)]?.color == color {
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
            if gameState[colIndex - counter, new_starting_row + counter] == nil {
                validBoardMoves.append((colIndex - counter, new_starting_row + counter))
            } else if gameState[colIndex - counter, new_starting_row + counter]?.color == color {
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
            if gameState[colIndex + counter, rowIndex + (counter * 2)] == nil {
                validBoardMoves.append((colIndex + counter, rowIndex + (counter * 2)))
            } else if gameState[colIndex + counter, rowIndex + (counter * 2)]?.color == color {
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
            if gameState[colIndex + counter, new_starting_row + counter] == nil {
                validBoardMoves.append((colIndex + counter, new_starting_row + counter))
            } else if gameState[colIndex + counter, new_starting_row + counter]?.color == color {
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
            if gameState[colIndex - counter, rowIndex - counter] == nil {
                validBoardMoves.append((colIndex - counter, rowIndex - counter))
            } else if gameState[colIndex - counter, rowIndex - counter]?.color == color {
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
            if gameState[colIndex - counter, new_starting_row - (downCounter * 2)] == nil {
                validBoardMoves.append((colIndex - counter, new_starting_row - (downCounter * 2)))
            } else if gameState[colIndex - counter, new_starting_row - (downCounter * 2)]?.color == color {
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
            if gameState[colIndex + counter, rowIndex - counter] == nil {
                validBoardMoves.append((colIndex + counter, rowIndex - counter))
            } else if gameState[colIndex + counter, rowIndex - counter]?.color == color {
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
            if gameState[colIndex + counter, new_starting_row - (downCounter * 2)] == nil {
                validBoardMoves.append((colIndex + counter, new_starting_row - (downCounter * 2)))
            } else if gameState[colIndex + counter, new_starting_row - (downCounter * 2)]?.color == color {
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
            if gameState[colIndex - (counter * 2), rowIndex + counter] == nil {
                validBoardMoves.append((colIndex - (counter * 2), rowIndex + counter))
            } else if gameState[colIndex - (counter * 2), rowIndex + counter]?.color == color {
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
            if gameState[colIndex - (counter * 2), new_starting_row] == nil {
                validBoardMoves.append((colIndex - (counter * 2), new_starting_row))
            } else if gameState[colIndex - (counter * 2), new_starting_row]?.color == color {
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
            if gameState[colIndex - (counter * 2), new_starting_row - counter] == nil {
                validBoardMoves.append((colIndex - (counter * 2), new_starting_row - counter))
            } else if gameState[colIndex - (counter * 2), new_starting_row - counter]?.color == color {
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
            if gameState[colIndex + (counter * 2), rowIndex + counter] == nil {
                validBoardMoves.append((colIndex + (counter * 2), rowIndex + counter))
            } else if gameState[colIndex + (counter * 2), rowIndex + counter]?.color == color {
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
            if gameState[colIndex + (counter * 2), new_starting_row] == nil {
                validBoardMoves.append((colIndex + (counter * 2), new_starting_row))
            } else if gameState[colIndex + (counter * 2), new_starting_row]?.color == color {
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
            if gameState[colIndex + (counter * 2), new_starting_row - counter] == nil {
                validBoardMoves.append((colIndex + (counter * 2), new_starting_row - counter))
            } else if gameState[colIndex + (counter * 2), new_starting_row - counter]?.color == color {
                break
            } else {
                validBoardMoves.append((colIndex + (counter * 2), new_starting_row - counter))
                break
            }
            counter += 1
        }

    return validBoardMoves
}

func validMovesForKing(_ color: String, at position: String, in gameState: GameState) -> [String] {
    guard let (colIndex, rowIndex) = parsePosition(position) else {
        print("Position only has string length of 1!")
        return []
    }
    return boardToHex(validMovesForKing(color, at: (colIndex, rowIndex), in: gameState))
}

func validMovesForKing(_ color: String, at position: (Int, Int), in gameState: GameState) -> [(Int, Int)] {
    var validBoardMoves: [(Int, Int)] = []
    let (colIndex, rowIndex) = position

    // King moves one tile in all directions: up, down, left, right, up left, up right, down left, down right, up diagonal left, up diagonal right, down diagonal left, and down diagonal right (12 total directions)

    // Move up
    if isValidPosition(columnToCheck: colIndex, rowToCheck: rowIndex + 1, in: gameState) {
        if gameState[colIndex, rowIndex + 1] == nil || gameState[colIndex, rowIndex + 1]?.color != color {
            validBoardMoves.append((colIndex, rowIndex + 1))
        }
    }

    // Move down
    if isValidPosition(columnToCheck: colIndex, rowToCheck: rowIndex - 1, in: gameState) {
        if gameState[colIndex, rowIndex - 1] == nil || gameState[colIndex, rowIndex - 1]?.color != color {
            validBoardMoves.append((colIndex, rowIndex - 1))
        }
    }

    // Move left
    if colIndex - 2 > 4 && isValidPosition(columnToCheck: colIndex - 2, rowToCheck: rowIndex + 1, in: gameState) {//on the right of the board
        if gameState[colIndex - 2, rowIndex + 1] == nil || gameState[colIndex - 2, rowIndex + 1]?.color != color {
            validBoardMoves.append((colIndex - 2, rowIndex + 1))
        }
    } else if colIndex - 2 == 4 && isValidPosition(columnToCheck: colIndex - 2, rowToCheck: rowIndex, in: gameState) {//crossing the midde column
        if gameState[colIndex - 2, rowIndex] == nil || gameState[colIndex - 2, rowIndex]?.color != color {
            validBoardMoves.append((colIndex - 2, rowIndex))
        }
    } else if colIndex - 2 < 4 && isValidPosition(columnToCheck: colIndex - 2, rowToCheck: rowIndex - 1, in: gameState) {// on the left of the board
        if gameState[colIndex - 2, rowIndex - 1] == nil || gameState[colIndex - 2, rowIndex - 1]?.color != color {
            validBoardMoves.append((colIndex - 2, rowIndex - 1))
        }
    }

    // Move right
    if colIndex + 2 < 6 && isValidPosition(columnToCheck: colIndex + 2, rowToCheck: rowIndex + 1, in: gameState) {//on the left of the board
        if gameState[colIndex + 2, rowIndex + 1] == nil || gameState[colIndex + 2, rowIndex + 1]?.color != color {
            validBoardMoves.append((colIndex + 2, rowIndex + 1))
        }
    } else if colIndex + 2 == 6 && isValidPosition(columnToCheck: colIndex + 2, rowToCheck: rowIndex, in: gameState) {//crossing the middle column
        if gameState[colIndex + 2, rowIndex] == nil || gameState[colIndex + 2, rowIndex]?.color != color {
            validBoardMoves.append((colIndex + 2, rowIndex))
        }
    } else if colIndex + 2 > 6 && isValidPosition(columnToCheck: colIndex + 2, rowToCheck: rowIndex - 1, in: gameState) {//on the right of the board
        if gameState[colIndex + 2, rowIndex - 1] == nil || gameState[colIndex + 2, rowIndex - 1]?.color != color {
            validBoardMoves.append((colIndex + 2, rowIndex - 1))
        }
    }

    // Move up left
    if colIndex - 1 >= 5 && isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex + 1, in: gameState) {//on the right of the board
        if gameState[colIndex - 1, rowIndex + 1] == nil || gameState[colIndex - 1, rowIndex + 1]?.color != color {
            validBoardMoves.append((colIndex - 1, rowIndex + 1))
        }
    } else if colIndex - 1 < 5 && isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex, in: gameState) {//on the middle/left of the board
        if gameState[colIndex - 1, rowIndex] == nil || gameState[colIndex - 1, rowIndex]?.color != color {
            validBoardMoves.append((colIndex - 1, rowIndex))
        }
    }

    // Move up right
    if colIndex + 1 <= 5 && isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex + 1, in: gameState) {//on the left of the board
        if gameState[colIndex + 1, rowIndex + 1] == nil || gameState[colIndex + 1, rowIndex + 1]?.color != color {
            validBoardMoves.append((colIndex + 1, rowIndex + 1))
        }
    } else if colIndex + 1 > 5 && isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex, in: gameState) {//on right middle/right of the board
        if gameState[colIndex + 1, rowIndex] == nil || gameState[colIndex + 1, rowIndex]?.color != color {
            validBoardMoves.append((colIndex + 1, rowIndex))
        }
    }

    // Move down left
    if colIndex - 1 >= 5 && isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex, in: gameState) {//on the right of the board
        if gameState[colIndex - 1, rowIndex] == nil || gameState[colIndex - 1, rowIndex]?.color != color {
            validBoardMoves.append((colIndex - 1, rowIndex))
        }
    } else if colIndex - 1 < 5 && isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex - 1, in: gameState) {// on the middle/left of the board
        if gameState[colIndex - 1, rowIndex - 1] == nil || gameState[colIndex - 1, rowIndex - 1]?.color != color {
            validBoardMoves.append((colIndex - 1, rowIndex - 1))
        }
    }

    // Move down right
    if colIndex + 1 <= 5 && isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex, in: gameState) {//on the left of the board
        if gameState[colIndex + 1, rowIndex] == nil || gameState[colIndex + 1, rowIndex]?.color != color {
            validBoardMoves.append((colIndex + 1, rowIndex))
        }
    } else if colIndex + 1 > 5 && isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex - 1, in: gameState) {//on the middle/right of the board
        if gameState[colIndex + 1, rowIndex - 1] == nil || gameState[colIndex + 1, rowIndex - 1]?.color != color {
            validBoardMoves.append((colIndex + 1, rowIndex - 1))
        }
    }
    
    // Move up left diagonal
    if colIndex - 1 >= 5 && isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex + 2, in: gameState) {//on the right of the board
        if gameState[colIndex - 1, rowIndex + 2] == nil || gameState[colIndex - 1, rowIndex + 2]?.color != color {
            validBoardMoves.append((colIndex - 1, rowIndex + 2))
        }
    } else if colIndex - 1 < 5 && isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex + 1, in: gameState) {//on the middle/left of the board
        if gameState[colIndex - 1, rowIndex + 1] == nil || gameState[colIndex - 1, rowIndex + 1]?.color != color {
            validBoardMoves.append((colIndex - 1, rowIndex + 1))
        }
    }
    
    // Move up right diagonal
    if colIndex + 1 <= 5 && isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex + 2, in: gameState) {//on the left of the board
        if gameState[colIndex + 1, rowIndex + 2] == nil || gameState[colIndex + 1, rowIndex + 2]?.color != color {
            validBoardMoves.append((colIndex + 1, rowIndex + 2))
        }
    } else if colIndex + 1 > 5 && isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex + 1, in: gameState) {//on the middle/right of the board
        if gameState[colIndex + 1, rowIndex + 1] == nil || gameState[colIndex + 1, rowIndex + 1]?.color != color {
            validBoardMoves.append((colIndex + 1, rowIndex + 1))
        }
    }
    
    // Move down left diagonal
    if colIndex - 1 >= 5 && isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex - 1, in: gameState) {//on the right of the board
        if gameState[colIndex - 1, rowIndex - 1] == nil || gameState[colIndex - 1, rowIndex - 1]?.color != color {
            validBoardMoves.append((colIndex - 1, rowIndex - 1))
        }
    } else if colIndex - 1 < 5 && isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex - 2, in: gameState) {//on the middle/left of the board
        if gameState[colIndex - 1, rowIndex - 2] == nil || gameState[colIndex - 1, rowIndex - 2]?.color != color {
            validBoardMoves.append((colIndex - 1, rowIndex - 2))
        }
    }
    
    // Move down right diagonal
    if colIndex + 1 <= 5 && isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex - 1, in: gameState) {//on the left of the board
        if gameState[colIndex + 1, rowIndex - 1] == nil || gameState[colIndex + 1, rowIndex - 1]?.color != color {
            validBoardMoves.append((colIndex + 1, rowIndex - 1))
        }
    } else if colIndex + 1 > 5 && isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex - 2, in: gameState) {//on the middle/right of the board
        if gameState[colIndex + 1, rowIndex - 2] == nil || gameState[colIndex + 1, rowIndex - 2]?.color != color {
            validBoardMoves.append((colIndex + 1, rowIndex - 2))
        }
    }
    
    return validBoardMoves
}

func validMovesForKnight(_ color: String, at position: String, in gameState: GameState) -> [String] {
    guard let (colIndex, rowIndex) = parsePosition(position) else {
        print("Position only has string length of 1!")
        return []
    }
    return boardToHex(validMovesForKnight(color, at: (colIndex, rowIndex), in: gameState))
}

func validMovesForKnight(_ color: String, at position: (Int, Int), in gameState: GameState) -> [(Int, Int)] {
    var validBoardMoves: [(Int, Int)] = []
    let (colIndex, rowIndex) = position

    func tryAddMove(col: Int, row: Int) {
        if isValidPosition(columnToCheck: col, rowToCheck: row, in: gameState),
           gameState[col, row] == nil || gameState[col, row]?.color != color {
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

    return validBoardMoves
}


private func filterMovesThatExposeKing(_ moves: [String], for color: String, at position: String, in gameState: inout GameState) -> [String] {
    //print("moves", moves, "for", color, "position", position)
    guard !moves.isEmpty else { return moves }

    // A move by a piece other than the king can only expose its own king to check if the king is
    // already in check (so it needs blocking/capturing) or the piece was pinned, blocking a sliding
    // attacker (rook/bishop/queen). If the opponent has no sliding pieces left, neither is possible,
    // so every pseudo-legal move is legal and we can skip the make/unmake simulation entirely.
    let opponentColor = color == "white" ? "black" : "white"
    let movingPieceType = gameState.pieceAt(position)?.type
    if movingPieceType != "king" {
        if gameState.sliderCount(for: opponentColor) == 0 {
            let kingAlreadyInCheck = isKingInCheckUsingKingSight(for: color, in: &gameState).0
            if !kingAlreadyInCheck {
                return moves
            }
        } else if movingPieceType != "pawn" {
            // Sliders are on the board, but a piece that isn't pinned to its own king can't expose
            // that king by moving (unless the king is already in check, which still needs the full
            // per-move check below). Pawns are excluded from this shortcut because an en passant
            // capture removes two pawns from the same rank at once, which can expose the king even
            // though neither pawn is individually pinned.
            let kingAlreadyInCheck = isKingInCheckUsingKingSight(for: color, in: &gameState).0
            if !kingAlreadyInCheck && !isPinned(position, for: color, in: &gameState) {
                return moves
            }
        }
    }

    return moves.filter { move in

        let undoInfo = gameState.makeMove(position, to: move)

        let kingInCheck = isKingInCheckUsingKingSight(for: color, in: &gameState) //can swap out this function for the commented out one, the commented out one fs works but is slow

        gameState.unmakeMove(position, to: move, undoInfo: undoInfo)

        return !kingInCheck.0
    }
}

// Determines whether the piece at `position` is pinned to its own king by a sliding attacker, by
// briefly removing it from the board and checking whether that opens the king's rook/bishop sight
// line to an enemy rook/queen or bishop/queen. This is far cheaper than simulating every one of the
// piece's candidate moves individually, since it costs a handful of ray scans per piece instead of
// per move.
private func isPinned(_ position: String, for color: String, in gameState: inout GameState) -> Bool {
    let opponentColor = color == "white" ? "black" : "white"
    let kingPosition = color == "white" ? gameState.whiteKingPosition : gameState.blackKingPosition
    let removedPiece = gameState.pieceAt(position)

    let rookSightBefore = Set(validMovesForRook(color, at: kingPosition, in: gameState))
    gameState.setPiece(nil, at: position)
    let rookSightAfter = validMovesForRook(color, at: kingPosition, in: gameState)
    gameState.setPiece(removedPiece, at: position)

    for square in rookSightAfter where !rookSightBefore.contains(square) {
        if let blocker = gameState.pieceAt(square), blocker.color == opponentColor,
           blocker.type == "rook" || blocker.type == "queen" {
            return true
        }
    }

    let bishopSightBefore = Set(validMovesForBishop(color, at: kingPosition, in: gameState))
    gameState.setPiece(nil, at: position)
    let bishopSightAfter = validMovesForBishop(color, at: kingPosition, in: gameState)
    gameState.setPiece(removedPiece, at: position)

    for square in bishopSightAfter where !bishopSightBefore.contains(square) {
        if let blocker = gameState.pieceAt(square), blocker.color == opponentColor,
           blocker.type == "bishop" || blocker.type == "queen" {
            return true
        }
    }

    return false
}

func isKingInCheckUsingKingSight(for color: String, in currentGameState: inout GameState) -> (Bool, String) {
    let kingPosition: String
    if color == "white" {
        kingPosition = currentGameState.whiteKingPosition
    } else {
        kingPosition = currentGameState.blackKingPosition
    }

    let opponentColor = color == "white" ? "black" : "white"

    // Rook/bishop/queen threats can only exist if the opponent still has a sliding piece on the
    // board, so the ray scans below are skipped entirely once that count hits zero
    if currentGameState.sliderCount(for: opponentColor) > 0 {
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
    let columns = hexColumns
    var validBoardMoves: [(Int, Int)] = []

    guard position.count >= 2,
          let columnLetter = position.first,
          var rowIndex = Int(String(position.dropFirst())),
          let colIndex = hexColumnIndex(for: columnLetter) else {
        print("Position only has string length of 1!")
        return boardToHex(validBoardMoves)
    }
    rowIndex = rowIndex - 1 // making it 0 indexed to work with gameState.board

    if color == "white" {
        // Capture logic for left and right
        if colIndex < 5 { // Left side of board
            //left on left
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex, in: gameState),
               gameState[colIndex - 1, rowIndex]?.color == "black" {
                validBoardMoves.append((colIndex - 1, rowIndex))
            }
            //right on left
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex + 1, in: gameState),
               gameState[colIndex + 1, rowIndex + 1]?.color == "black" {
                validBoardMoves.append((colIndex + 1, rowIndex + 1))
            }
        } else if colIndex == 5 { // Center of board
            //left on center
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex, in: gameState),
               gameState[colIndex - 1, rowIndex]?.color == "black" {
                validBoardMoves.append((colIndex - 1, rowIndex))
            }
            //right on center
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex, in: gameState),
               gameState[colIndex + 1, rowIndex]?.color == "black" {
                validBoardMoves.append((colIndex + 1, rowIndex))
            }
        } else { // Right side of board
            //left on right
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex + 1, in: gameState),
               gameState[colIndex - 1, rowIndex + 1]?.color == "black" {
                validBoardMoves.append((colIndex - 1, rowIndex + 1))
            }
            //right on right
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex, in: gameState),
               gameState[colIndex + 1, rowIndex]?.color == "black" {
                validBoardMoves.append((colIndex + 1, rowIndex))
            }
        }
    }

    if color == "black" {
        // Capture logic for left and right
        if colIndex < 5 { // Left side of board
            //left on left
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex - 1, in: gameState),
               gameState[colIndex - 1, rowIndex - 1]?.color == "white" {
                validBoardMoves.append((colIndex - 1, rowIndex - 1))
            }
            //right on left
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex, in: gameState),
               gameState[colIndex + 1, rowIndex]?.color == "white" {
                validBoardMoves.append((colIndex + 1, rowIndex))
            }
        } else if colIndex == 5 { // Center of board
            //left on center
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex - 1, in: gameState),
               gameState[colIndex - 1, rowIndex - 1]?.color == "white" {
                validBoardMoves.append((colIndex - 1, rowIndex - 1))
            }
            //right on center
            if isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex - 1, in: gameState),
               gameState[colIndex + 1, rowIndex - 1]?.color == "white" {
                validBoardMoves.append((colIndex + 1, rowIndex - 1))
            }
        } else { // Right side of board
            //left on right
            if isValidPosition(columnToCheck: colIndex - 1, rowToCheck: rowIndex, in: gameState),
               gameState[colIndex - 1, rowIndex]?.color == "white" {
                validBoardMoves.append((colIndex - 1, rowIndex))
            }
            //right on right
            if colIndex + 1 < columns.count,
               isValidPosition(columnToCheck: colIndex + 1, rowToCheck: rowIndex - 1, in: gameState),
               gameState[colIndex + 1, rowIndex - 1]?.color == "white" {
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
    let columns = hexColumns
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
