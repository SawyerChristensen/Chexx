//
//  PieceRules.swift
//  Chexx
//
//  Created by Sawyer Christensen on 7/4/24.
//

import Foundation
import SpriteKit

func validMovesForPiece(_ piece: SKSpriteNode, in gameState: GameState) -> [String] {
    let pieceDetails = piece.name?.split(separator: "_") ?? []
    guard pieceDetails.count == 3 else { return [] }
    
    let color = String(pieceDetails[1])
    let type = String(pieceDetails[2])
    
    switch type {
    case "pawn":
        return validMovesForPawn(color, at: String(pieceDetails[0]), in: gameState)
    // Add other piece types here as needed
    default:
        return []
    }
}

//this needs to be changed later and im not doing it now bruh
private func validMovesForPawn(_ color: String, at position: String, in gameState: GameState) -> [String] {
    let columns = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "k", "l"]
    var validMoves: [String] = []
    
    guard position.count == 2,
          let columnLetter = position.first,
          var rowIndex = Int(String(position.last!)), //not 0 indexed!
          let colIndex = columns.firstIndex(of: String(columnLetter)) else {
        return validMoves
    }
    rowIndex = rowIndex - 1 //making it 0 indexed to work with gameState.board
    
    //note: validmoves rowIndex is 0 indexed when accessing gameState.board, but shouldn't be when appended to validMoves, always increase by 1 in the return statement
    if color == "white" {
        // Move up 1
        if rowIndex + 1 < gameState.board[colIndex].count,
           gameState.board[colIndex][rowIndex + 1] == nil {
            validMoves.append("\(columnLetter)\(rowIndex + 2)")
            
            // If it hasn't moved at all, bonus move!
            if !gameState.board[colIndex][rowIndex]!.hasMoved, //if it hasnt moved
               gameState.board[colIndex][rowIndex + 1] == nil, //and its not skipping over a piece
               gameState.board[colIndex][rowIndex + 2] == nil { //and the destination is free
                validMoves.append("\(columnLetter)\(rowIndex + 3)") //opening bonus 2 tiles!
            }
        }
        // Capture logic for left and right
        if colIndex < 5 { // Left side of board
            if colIndex - 1 >= 0,
               rowIndex + 1 < gameState.board[colIndex - 1].count,
               gameState.board[colIndex - 1][rowIndex + 1]?.color == "black" {
                validMoves.append("\(columns[colIndex - 1])\(rowIndex + 2)")
            }
            if colIndex + 1 < columns.count,
               rowIndex + 1 < gameState.board[colIndex + 1].count,
               gameState.board[colIndex + 1][rowIndex + 1]?.color == "black" {
                validMoves.append("\(columns[colIndex + 1])\(rowIndex + 2)")
            }
        } else if colIndex == 5 { // Center of board
            if colIndex - 1 >= 0,
               gameState.board[colIndex - 1][rowIndex]?.color == "black" {
                validMoves.append("\(columns[colIndex - 1])\(rowIndex + 1)")
            }
            if colIndex + 1 < columns.count,
               gameState.board[colIndex + 1][rowIndex]?.color == "black" {
                validMoves.append("\(columns[colIndex + 1])\(rowIndex + 1)")
            }
        } else { // Right side of board
            if colIndex - 1 >= 0,
               rowIndex + 1 < gameState.board[colIndex - 1].count,
               gameState.board[colIndex - 1][rowIndex + 1]?.color == "black" {
                validMoves.append("\(columns[colIndex - 1])\(rowIndex + 2)")
            }
            if colIndex + 1 < columns.count,
               rowIndex < gameState.board[colIndex + 1].count,
               gameState.board[colIndex + 1][rowIndex]?.color == "black" {
                validMoves.append("\(columns[colIndex + 1])\(rowIndex + 1)")
            }
        }
    }
    
    return validMoves
}
