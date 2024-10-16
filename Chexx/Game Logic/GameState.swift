//
//  GameState.swift
//  Chexx
//
//  Created by Sawyer Christensen on 6/29/24.
//

import SpriteKit

struct Piece: Codable {
    var color: String // "white" or "black"
    var type: String // "pawn" or "rook" etc
    var hasMoved: Bool = false // for pawns to check if they still have their opening two moves
    var isEnPassantTarget: Bool = false //if pawns have moved two, it opens them up for temporary en passant capture!!
}

struct GameState: Codable {
    var currentPlayer: String // "white" or "black"
    var gameStatus: String // "ongoing" or "ended" //can probably change this into a bool "isOngoing" later
    var board: [[Piece?]] // 2D array of optional pieces
    
    var whiteKingPosition: String
    var blackKingPosition: String
    
    var variant: String = "Glinski's"
    var HexFen: [UInt8] = []
    
    init(/*variant: String*/) {
        //self.variant = variant
        // Initialize the board with nils (empty positions)
        //let columns = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "k", "l"]
        let columnSizes = [6, 7, 8, 9, 10, 11, 10, 9, 8, 7, 6]
        board = []
        
        for size in columnSizes {
            var column: [Piece?] = []
            for _ in 0..<size {
                column.append(nil) //nil signifies an empty hextile
            }
            board.append(column)
        }
        
        // Set initial game metadata
        currentPlayer = "white"
        gameStatus = "ongoing"
        whiteKingPosition = "g1"
        blackKingPosition = "g10"
        HexFen = []
        
        //print(variant)
        
        if variant == "Glinski's" {
            HexFen.append(00)
        } else if variant == "Mathewson's" {
            HexFen.append(01)
        } else if variant == "McCooey's" {
            HexFen.append(10)
        } else if variant == "Christensen's" {
            HexFen.append(11)
        }
        
        // Set initial pieces on the board
        setInitialPiecePositions() //could maybe be incorporated into the if else
    }
    /*
    mutating func setInitialPiecePositions() {
        switch variant {
        case "Glinski's":
            setGlinskisPiecePositions()
        case "Mathewson's":
            setMathewsonsPiecePositions()
        case "McCooey's":
            setMathewsonsPiecePositions()
        default:
            setGlinskisPiecePositions() // Default to Glinski's
        }
    }*/
    
    mutating func setInitialPiecePositions() { //when enabling variants, this is private mutating func setGlinskisPiecePositions()
        let initialPositions: [((Int, Int), Piece)] = [
            ((1, 6), Piece(color: "black", type: "pawn")),
            ((2, 6), Piece(color: "black", type: "pawn")),
            ((3, 6), Piece(color: "black", type: "pawn")),
            ((4, 6), Piece(color: "black", type: "pawn")),
            ((5, 6), Piece(color: "black", type: "pawn")),
            ((6, 6), Piece(color: "black", type: "pawn")),
            ((7, 6), Piece(color: "black", type: "pawn")),
            ((8, 6), Piece(color: "black", type: "pawn")),
            ((9, 6), Piece(color: "black", type: "pawn")),
            ((1, 0), Piece(color: "white", type: "pawn")),
            ((2, 1), Piece(color: "white", type: "pawn")),
            ((3, 2), Piece(color: "white", type: "pawn")),
            ((4, 3), Piece(color: "white", type: "pawn")),
            ((5, 4), Piece(color: "white", type: "pawn")),
            ((6, 3), Piece(color: "white", type: "pawn")),
            ((7, 2), Piece(color: "white", type: "pawn")),
            ((8, 1), Piece(color: "white", type: "pawn")),
            ((9, 0), Piece(color: "white", type: "pawn")),
            ((2, 7), Piece(color: "black", type: "rook")),
            ((8, 7), Piece(color: "black", type: "rook")),
            ((3, 8), Piece(color: "black", type: "knight")),
            ((4, 9), Piece(color: "black", type: "queen")),
            ((5, 10), Piece(color: "black", type: "bishop")),
            ((5, 9), Piece(color: "black", type: "bishop")),
            ((5, 8), Piece(color: "black", type: "bishop")),
            ((6, 9), Piece(color: "black", type: "king")),
            ((7, 8), Piece(color: "black", type: "knight")),
            ((2, 0), Piece(color: "white", type: "rook")),
            ((3, 0), Piece(color: "white", type: "knight")),
            ((4, 0), Piece(color: "white", type: "queen")),
            ((5, 0), Piece(color: "white", type: "bishop")),
            ((5, 1), Piece(color: "white", type: "bishop")),
            ((5, 2), Piece(color: "white", type: "bishop")),
            ((6, 0), Piece(color: "white", type: "king")),
            ((7, 0), Piece(color: "white", type: "knight")),
            ((8, 0), Piece(color: "white", type: "rook"))
        ]
        
        for ((col, row), piece) in initialPositions {
            board[col][row] = piece
        }
    }
    
    /*private mutating func setMathewsonsPiecePositions() {
        let initialPositions: [((Int, Int), Piece)] = [
            ((1, 6), Piece(color: "black", type: "pawn")),
            ((2, 6), Piece(color: "black", type: "pawn")),
            ((3, 7), Piece(color: "black", type: "pawn")),
            ((4, 7), Piece(color: "black", type: "pawn")),
            ((5, 7), Piece(color: "black", type: "pawn")),
            ((6, 7), Piece(color: "black", type: "pawn")),
            ((7, 7), Piece(color: "black", type: "pawn")),
            ((8, 6), Piece(color: "black", type: "pawn")),
            ((9, 6), Piece(color: "black", type: "pawn")),
            ((1, 0), Piece(color: "white", type: "pawn")),
            ((2, 1), Piece(color: "white", type: "pawn")),
            ((3, 1), Piece(color: "white", type: "pawn")),
            ((4, 2), Piece(color: "white", type: "pawn")),
            ((5, 3), Piece(color: "white", type: "pawn")),
            ((6, 2), Piece(color: "white", type: "pawn")),
            ((7, 1), Piece(color: "white", type: "pawn")),
            ((8, 1), Piece(color: "white", type: "pawn")),
            ((9, 0), Piece(color: "white", type: "pawn")),
            ((2, 7), Piece(color: "black", type: "rook")),
            ((8, 7), Piece(color: "black", type: "rook")),
            ((3, 8), Piece(color: "black", type: "knight")),
            ((4, 9), Piece(color: "black", type: "queen")),
            ((5, 10), Piece(color: "black", type: "bishop")),
            ((5, 9), Piece(color: "black", type: "bishop")),
            ((5, 8), Piece(color: "black", type: "bishop")),
            ((6, 9), Piece(color: "black", type: "king")),
            ((7, 8), Piece(color: "black", type: "knight")),
            ((2, 0), Piece(color: "white", type: "rook")),
            ((3, 0), Piece(color: "white", type: "knight")),
            ((4, 0), Piece(color: "white", type: "queen")),
            ((5, 0), Piece(color: "white", type: "bishop")),
            ((5, 1), Piece(color: "white", type: "bishop")),
            ((5, 2), Piece(color: "white", type: "bishop")),
            ((6, 0), Piece(color: "white", type: "king")),
            ((7, 0), Piece(color: "white", type: "knight")),
            ((8, 0), Piece(color: "white", type: "rook"))
        ]
        
        for ((col, row), piece) in initialPositions {
            board[col][row] = piece
        }
    }*/
    
    func copy() -> GameState {
        // Create a deep copy of the board
        let copiedBoard = board.map { column in
            column.map { $0 }
        }
        
        // Return a new GameState with copied properties
        return GameState(
            currentPlayer: currentPlayer,
            gameStatus: gameStatus,
            board: copiedBoard,
            whiteKingPosition: whiteKingPosition,
            blackKingPosition: blackKingPosition,
            //variant: variant,
            HexFen: HexFen
        )
    }
    
    // New initializer to use in the copy method
    init(currentPlayer: String, gameStatus: String, board: [[Piece?]], whiteKingPosition: String, blackKingPosition: String, /*variant: String,*/ HexFen: [UInt8]) {
        self.currentPlayer = currentPlayer
        self.gameStatus = gameStatus
        self.board = board
        self.whiteKingPosition = whiteKingPosition
        self.blackKingPosition = blackKingPosition
        //self.variant = variant
        self.HexFen = HexFen
    }

    mutating func movePiece(from: String, to: String) {
        let columns = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "k", "l"]
        
        // Convert from and to positions to board indices
        guard let fromColumn = columns.firstIndex(of: String(from.first!)),
              let fromRow = Int(from.dropFirst()),
              let toColumn = columns.firstIndex(of: String(to.first!)),
              let toRow = Int(to.dropFirst()) else {
            return
        }

        // Adjust for 0-based indexing
        let fromIndex = (fromColumn, fromRow - 1)
        let toIndex = (toColumn, toRow - 1)
        
        // Move the piece on the board
        let pieceToMove = board[fromIndex.0][fromIndex.1]
        board[fromIndex.0][fromIndex.1] = nil
        board[toIndex.0][toIndex.1] = pieceToMove
        
        // Update king position if necessary
        if pieceToMove?.type == "king" {
            //print("updating king position from", from, "to", to)
            if pieceToMove?.color == "white" {
                whiteKingPosition = "\(columns[toColumn])\(toRow)"
            } else if pieceToMove?.color == "black" {
                blackKingPosition = "\(columns[toColumn])\(toRow)"
            }
        }
    }
    
    mutating func addMoveToHexFen(from: String, to: String) {
        let originInt = positionStringToInt(position: from)
        let destinationInt = positionStringToInt(position: to)
        
        HexFen.append(UInt8(originInt))
        HexFen.append(UInt8(destinationInt))
        
        print(HexFen)
        
        for value in HexFen {
            // Convert each UInt8 to a binary string with leading zeros
            let binaryString = String(value, radix: 2).leftPadded(toLength: 8, withPad: "0")
            print(binaryString)
        }
    }
    
    func positionStringToInt(position: String) -> Int {
        let columns = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "k", "l"]
        
        // Convert from and to positions to board indices
        guard let columnPos = columns.firstIndex(of: String(position.first!)),
              var rowPos = Int(position.dropFirst()) else {
            return 0
        }
        
        rowPos = rowPos - 1 //input String is not 0-indexed
        
        //let columnSizes = [6, 7, 8, 9, 10, 11, 10, 9, 8, 7, 6]
        
        var columnOffset: Int = 0

        if columnPos == 0 { //index of "a" in columns
            columnOffset = 0
        } else if columnPos == 1 { //index of "b" in columns
            columnOffset = 6
        } else if columnPos == 2 { //index of "c" in columns
            columnOffset = 13       //6 + 7
        } else if columnPos == 3 { //index of "d" in columns
            columnOffset = 21       //6 + 7 + 8
        } else if columnPos == 4 { //index of "e" in columns
            columnOffset = 30       //6 + 7 + 8 + 9
        } else if columnPos == 5 { //index of "f" in columns
            columnOffset = 40       //6 + 7 + 8 + 9 + 10
        } else if columnPos == 6 { //index of "g" in columns
            columnOffset = 51       //6 + 7 + 8 + 9 + 10 + 11
        } else if columnPos == 7 { //index of "h" in columns
            columnOffset = 61       //6 + 7 + 8 + 9 + 10 + 11 + 10
        } else if columnPos == 8 { //index of "i" in columns
            columnOffset = 70       //6 + 7 + 8 + 9 + 10 + 11 + 10 + 9
        } else if columnPos == 9 { //index of "k" in columns
            columnOffset = 78       //6 + 7 + 8 + 9 + 10 + 11 + 10 + 9 + 8
        } else if columnPos == 10 { //index of "l" in columns
            columnOffset = 85       //6 + 7 + 8 + 9 + 10 + 11 + 10 + 9 + 8 + 7
        }
        
        return columnOffset + rowPos
    }
    
    /*func compressBoardToBits() -> [Bool] {
        var bitArray = [Bool]()

        // Encode current player (1st bit) (0 = white, 1 = black)
        bitArray.append(currentPlayer == "black")

        // Encode empty tiles (0) and pieces (1 + Huffman code)
        for column in board {
            for tile in column {
                if let piece = tile {
                    bitArray.append(true) // Tile is occupied, append 1
                    
                    // Encode the color of the piece (append 0 for white, 1 for black)
                    bitArray.append(piece.color == "black")

                    // Encode piece type using Huffman codes
                    switch piece.type {
                    case "pawn":
                        bitArray.append(false) // 0 for pawn
                        bitArray.append(piece.hasMoved) // its moved, append 1
                        bitArray.append(piece.isEnPassantTarget) //if enpassant target, append 1
                    case "knight":
                        bitArray.append(contentsOf: [true, false, false]) // 100 for knight
                    case "bishop":
                        bitArray.append(contentsOf: [true, false, true]) // 101 for bishop
                    case "rook":
                        bitArray.append(contentsOf: [true, true, false]) // 110 for rook
                    case "queen":
                        bitArray.append(contentsOf: [true, true, true, true]) // 1111 for queen
                    case "king":
                        bitArray.append(contentsOf: [true, true, true, false]) // 1110 for king
                    default:
                        break
                    }
                } else {
                    bitArray.append(false) // Tile is empty
                }
            }
        }

        return bitArray
    }
    
    func flattenBitArrayToBytes(_ bitArray: [Bool]) -> [UInt8] { //a list of bools in swift is actually an array of bytes, but they represent true or false, 0/1 values, which can be flattend to bits, and then stored in bits again, representing an 8x reduction in space needed. actual storage of a hexchess board should be ~240 bits, or 30 bytes
        var byteArray = [UInt8](repeating: 0, count: (bitArray.count + 7) / 8) // Calculate required bytes

        for i in 0..<bitArray.count {
            if bitArray[i] {
                byteArray[i / 8] |= (1 << (7 - i % 8)) // Set the corresponding bit
            }
        }

        return byteArray
    }*/
}



//we can kind of ignore these two functions for now, might modify later
//rn is saves the game state in a bulky format, it stores the dictionary struct gamestate
//before launch we should have it convert the game state to algebraic chess notation, then save that in a json file or whatever
//this could cut down the game file save by like 20x, probably more. must implement this before launch
//would also need to change the load game state file to accept algebraic notation from the save file
//can do later though https://en.wikipedia.org/wiki/Algebraic_notation_(chess)


func saveGameStateToFile(_ gameState: GameState, to filename: String) { // i think this saves it to a file? this isnt used rn but need to implement later
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(gameState) {
        let url = getDocumentsDirectory().appendingPathComponent(filename)
        do {
            try encoded.write(to: url)
            print("Game state saved to \(url.path)")
        } catch {
            print("Failed to save game state: \(error.localizedDescription)")
        }
    }
}

func loadGameStateFromFile(from filename: String) -> GameState? {
    let url = getDocumentsDirectory().appendingPathComponent(filename)
    if let data = try? Data(contentsOf: url) {
        let decoder = JSONDecoder()
        if let gameState = try? decoder.decode(GameState.self, from: data) {
            return gameState
        }
    }
    return nil
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

extension String {
    func leftPadded(toLength length: Int, withPad character: Character) -> String {
        let padding = String(repeating: character, count: max(0, length - self.count))
        return padding + self
    }
}
