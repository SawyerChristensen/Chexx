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

struct MoveUndoInfo { //for simulating moves in advance with makeMove/unmakeMove
    let fromColIndex: Int
    let fromRowIndex: Int
    let toColIndex: Int
    let toRowIndex: Int
    let movingPiece: Piece?
    let capturedPiece: Piece?
}

struct GameState: Codable {
    var currentPlayer: String // "white" or "black"
    var gameStatus: String // "ongoing" or "ended" //can probably change this into a bool "isOngoing" later
    var board: [[Piece?]] // 2D array of optional pieces
    
    var whiteKingPosition: String
    var blackKingPosition: String
    
    var variant: String = "Glinski's"
    var HexPgn: [UInt8] = []
    
    init() {
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
        HexPgn = []
        
        if variant == "Glinski's" {
            HexPgn.append(00)
        } else if variant == "Mathewson's" {
            HexPgn.append(01)
        } else if variant == "McCooey's" {
            HexPgn.append(10)
        } else if variant == "Christensen's" {
            HexPgn.append(11)
        }
        
        // Set initial pieces on the board
        setInitialPiecePositions() //could maybe be incorporated into the if else
    }
    
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

    mutating func movePiece(from: String, to: String, promotionPiece: Piece?) {
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
        
        var pieceToMove = board[fromIndex.0][fromIndex.1]

        if promotionPiece != nil {
            pieceToMove = promotionPiece
        }
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
    
    mutating func makeMove(_ from: String, to: String) -> MoveUndoInfo { //able to undo this with the output info, not with movePiece()
        let columns = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "k", "l"]
        let fromColLetter = String(from.prefix(1))
        let fromRowString = String(from.dropFirst())
        let toColLetter = String(to.prefix(1))
        let toRowString = String(to.dropFirst())

        guard let fromColIndex = columns.firstIndex(of: fromColLetter),
              let toColIndex = columns.firstIndex(of: toColLetter),
              let fromRowIndex = Int(fromRowString).map({ $0 - 1 }),
              let toRowIndex = Int(toRowString).map({ $0 - 1 }) else {
            fatalError("Invalid move coordinates")
        }

        let movingPiece = board[fromColIndex][fromRowIndex]
        let capturedPiece = board[toColIndex][toRowIndex]

        // Update the board
        board[toColIndex][toRowIndex] = movingPiece
        board[fromColIndex][fromRowIndex] = nil

        // Update king's position if necessary
        if movingPiece?.type == "king" {
            if movingPiece?.color == "white" {
                whiteKingPosition = "\(columns[toColIndex])\(toRowIndex + 1)"
            } else if movingPiece?.color == "black" {
                blackKingPosition = "\(columns[toColIndex])\(toRowIndex + 1)"
            }
        }

        // Store undo information
        let undoInfo = MoveUndoInfo(
            fromColIndex: fromColIndex,
            fromRowIndex: fromRowIndex,
            toColIndex: toColIndex,
            toRowIndex: toRowIndex,
            movingPiece: movingPiece,
            capturedPiece: capturedPiece
        )

        return undoInfo
    }

    mutating func unmakeMove(_ from: String, to: String, undoInfo: MoveUndoInfo) {
        // Restore the board
        board[undoInfo.fromColIndex][undoInfo.fromRowIndex] = undoInfo.movingPiece
        board[undoInfo.toColIndex][undoInfo.toRowIndex] = undoInfo.capturedPiece

        // Restore the king's position if necessary
        if let movingPiece = undoInfo.movingPiece, movingPiece.type == "king" {
            let columns = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "k", "l"]
            if movingPiece.color == "white" {
                whiteKingPosition = "\(columns[undoInfo.fromColIndex])\(undoInfo.fromRowIndex + 1)"
            } else if movingPiece.color == "black" {
                blackKingPosition = "\(columns[undoInfo.fromColIndex])\(undoInfo.fromRowIndex + 1)"
            }
        }
    }
    
    mutating func addMoveToHexPgn(from: String, to: String, promotionOffset: UInt8) {
        let originInt = positionStringToInt(position: from)
        let destinationInt = positionStringToInt(position: to)
        
        HexPgn.append(UInt8(originInt))
        HexPgn.append(UInt8(destinationInt + promotionOffset))
        
        //print(HexPgn) //for testing
        /*
        for value in HexPgn {
            // Convert each UInt8 to a binary string with leading zeros
            let binaryString = String(value, radix: 2).leftPadded(toLength: 8, withPad: "0")
            print(binaryString)
        }*/
    }
    
    func positionStringToInt(position: String) -> UInt8 {
        let columns = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "k", "l"]
        let columnOffsets = [0, 6, 13, 21, 30, 40, 51, 61, 70, 78, 85] // Precomputed offsets

        // Convert from and to positions to board indices
        guard let columnPos = columns.firstIndex(of: String(position.first!)),
              var rowPos = Int(position.dropFirst()) else {
            return 0
        }

        rowPos -= 1 // Input String is not 0-indexed

        // Use the columnPos to fetch the corresponding offset
        let columnOffset = columnOffsets[columnPos]

        return UInt8(columnOffset + rowPos)
    }
    
    func positionIntToString(index: UInt8) -> String {
        let columns = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "k", "l"]
        let columnSizes = [6, 7, 8, 9, 10, 11, 10, 9, 8, 7, 6]
        
        var remainingIndex = index
        var columnPos = 0
        
        // Find the correct column based on the index range
        for (i, size) in columnSizes.enumerated() {
            if remainingIndex < size {
                columnPos = i
                break
            }
            remainingIndex -= UInt8(size)
        }
        
        // Convert remainingIndex back to row number (1-indexed)
        let rowPos = remainingIndex + 1
        
        // Combine column letter and row number into position string
        let columnLetter = columns[columnPos]
        return "\(columnLetter)\(rowPos)"
    }
    
    mutating func HexPgnToGameState(pgn: [UInt8]) -> GameState { //this assumes its operating on an blank gameState/new board
        guard pgn.count >= 1 else {
            print("Invalid HexPgn: Not enough data")
            return self
        }
        
        self.HexPgn = pgn

        //let variant = pgn[0] //first uint8 is the variant identifier
        //print("Variant used: \(variant)") //0 means Glinkskis //rn thats default

        // Iterate through the remaining UInt8s in pairs (skipping the first one)
        for i in stride(from: 1, to: pgn.count, by: 2) {
            let fromIndex = pgn[i]
            let toIndex = pgn[i + 1]
            
            var adjustedIndex = UInt8(0)
            var promotionPiece: Piece?
            
            currentPlayer = (((i - 1) / 2) % 2 == 0) ? "white" : "black"
            
            if toIndex > 91 { //pawn getting promoted!
                if currentPlayer == "white" {
                    promotionPiece = getPromotionPiece(for: toIndex)
                } else {
                    promotionPiece = getPromotionPiece(for: toIndex - 1)
                }
                
                switch promotionPiece?.type {
                    case "queen":
                        adjustedIndex = 91
                    case "rook":
                        adjustedIndex = 92
                    case "bishop":
                        adjustedIndex = 93
                    case "knight":
                        adjustedIndex = 94
                    default:
                        adjustedIndex = 0
                    }
            }

            // Convert indices to position strings
            let fromPosition = positionIntToString(index: fromIndex)
            let toPosition = positionIntToString(index: toIndex - adjustedIndex)

            // Perform the move
            movePiece(from: fromPosition, to: toPosition, promotionPiece: promotionPiece)
        }
        
        // Determine the current player's turn based on the number of moves
        let moveCount = (pgn.count - 1) / 2
        currentPlayer = (moveCount % 2 == 0) ? "white" : "black"

        // Return the updated game state
        return self
    }
    
    func getPromotionPiece(for index: UInt8) -> Piece? { //helper function for HexPgnToGameState
        let queenPromotionIndexArray: [UInt8] = [91, 96, 103, 111, 120, 130, 141, 151, 160, 168, 175, 181]
        let rookPromotionIndexArray: [UInt8] = [92, 97, 104, 112, 121, 131, 142, 152, 161, 169, 176, 182]
        let bishopPromotionIndexArray: [UInt8] = [93, 98, 105, 113, 122, 132, 143, 153, 162, 170, 177, 183]
        let knightPromotionIndexArray: [UInt8] = [94, 99, 106, 114, 123, 133, 144, 154, 163, 171, 178, 184]
        
        if queenPromotionIndexArray.contains(index) {
            return Piece(color: currentPlayer, type: "queen")
        } else if rookPromotionIndexArray.contains(index) {
            return Piece(color: currentPlayer, type: "rook")
        } else if bishopPromotionIndexArray.contains(index) {
            return Piece(color: currentPlayer, type: "bishop")
        } else if knightPromotionIndexArray.contains(index) {
            return Piece(color: currentPlayer, type: "knight")
        }
        return nil
    }

    
    func pieceAt(_ position: String) -> Piece? {
        let columns = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "k", "l"]
        let colLetter = String(position.prefix(1))
        let rowString = String(position.dropFirst())

        guard let colIndex = columns.firstIndex(of: colLetter),
              let rowIndex = Int(rowString).map({ $0 - 1 }) else {
            return nil
        }

        return board[colIndex][rowIndex]
    }
    /*
    func findKingPosition(for color: String) -> String? {
        let kingPosition: String
        
        if color == "white" {
            kingPosition = self.whiteKingPosition
        } else {
            kingPosition = self.blackKingPosition
        }
        
        return kingPosition
    }*/
    
    mutating func findCheckingPieces(kingPosition: String, color: String) -> [String] {
        var checkingPieces: [String] = []
        let opponentColor = color == "white" ? "black" : "white"
        
        // Rook and Queen threats (straight-line moves)
        let rookMoves = validMovesForRook(color, at: kingPosition, in: self)
        for position in rookMoves {
            if let piece = pieceAt(position),
               piece.color == opponentColor,
               (piece.type == "rook" || piece.type == "queen") {
                checkingPieces.append(position)
            }
        }

        // Bishop and Queen threats (diagonal moves)
        let bishopMoves = validMovesForBishop(color, at: kingPosition, in: self)
        for position in bishopMoves {
            if let piece = pieceAt(position),
               piece.color == opponentColor,
               (piece.type == "bishop" || piece.type == "queen") {
                checkingPieces.append(position)
            }
        }

        // Knight threats (L-shaped moves)
        let knightMoves = validMovesForKnight(color, at: kingPosition, in: self)
        for position in knightMoves {
            if let piece = pieceAt(position),
               piece.color == opponentColor,
               piece.type == "knight" {
                checkingPieces.append(position)
            }
        }

        // Pawn threats (single-step diagonal moves towards the king)
        let pawnMoves = pawnPureCaptures(color, at: kingPosition, in: self)
        for position in pawnMoves {
            if let piece = pieceAt(position),
               piece.color == opponentColor,
               piece.type == "pawn" {
                checkingPieces.append(position)
            }
        }

        return checkingPieces
    }

    mutating func hasLegalMovesForCurrentPlayer() -> Bool {
        let columns = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "k", "l"]
        for (colIndex, column) in board.enumerated() {
            for (rowIndex, piece) in column.enumerated() {
                if let piece = piece, piece.color == currentPlayer {
                    let currentPosition = "\(columns[colIndex])\(rowIndex + 1)"
                    let validMoves = validMovesForPiece(at: currentPosition, color: piece.color, type: piece.type, in: &self)
                    if !validMoves.isEmpty {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    mutating func isGameOver() -> (Bool, String) {
        let kingPosition = currentPlayer == "white" ? whiteKingPosition : blackKingPosition

        // Step 1: Check if the current player is in check
        let checkingPieces = findCheckingPieces(kingPosition: kingPosition, color: currentPlayer)
        let inCheck = !checkingPieces.isEmpty

        // Step 2: Check if there are any valid moves for the current player
        let hasLegalMoves = hasLegalMovesForCurrentPlayer()

        if inCheck {
            if !hasLegalMoves {
                return (true, "checkmate")
            }
            let checkingPiecesText = checkingPieces.joined(separator: ", ") //could also use an array but I dont want to return 3 seperate data types on i mean come on
            return (false, "check by \(checkingPiecesText)")
        } else if !hasLegalMoves {
            return (true, "stalemate")
        }

        return (false, "")  // Game is still ongoing
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

func saveGameStateToFile(hexPgn: [UInt8], to filename: String) {
    let saveData = HexPgnSaveData(date: Date(), hexPgn: hexPgn)
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601 // Standard format for date

    if let encoded = try? encoder.encode(saveData) {
        let url = getDocumentsDirectory().appendingPathComponent(filename)
        do {
            try encoded.write(to: url)
            //print("HexPgn saved to \(url.path)")
        } catch {
            print("Failed to save HexPgn: \(error.localizedDescription)")
        }
    }
}

func loadGameStateFromFile(from filename: String) -> GameState? {
    let url = getDocumentsDirectory().appendingPathComponent(filename)
    if let data = try? Data(contentsOf: url) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        if let saveData = try? decoder.decode(HexPgnSaveData.self, from: data) {
            var gameState = GameState() // Initialize empty GameState
            gameState = gameState.HexPgnToGameState(pgn: saveData.hexPgn) // Rebuild from HexPgn
            print("Game state loaded from \(url.path)") //STILL AN ISSUE WITH RELOADING THE GAMESTATE EVERY UI UPDATE, NEED TO CHANGE
            return gameState
        }
    }
    return nil
}

func deleteGameFile(filename: String) {
    let url = getDocumentsDirectory().appendingPathComponent(filename)
    
    do {
        try FileManager.default.removeItem(at: url)
        //print("Successfully deleted game file: \(url.path)")
    } catch {
        print("Failed to delete game file: \(error.localizedDescription)")
    }
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

struct HexPgnSaveData: Codable {
    let date: Date
    let hexPgn: [UInt8]
}
