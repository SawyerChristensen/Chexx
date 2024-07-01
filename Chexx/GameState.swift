//
//  GameState.swift
//  Chexx
//
//  Created by Sawyer Christensen on 6/29/24.
//

import Foundation

struct Piece: Codable {
    var color: String // "white" or "black"
    var type: String // "pawn" or "rook" etc
}

struct GameState: Codable {
    var board: [[Piece?]] // 2D array of optional pieces
    var currentPlayer: String // "white" or "black"
    var gameStatus: String // "ongoing" or "ended"
    
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
        
        // Set initial pieces on the board
        setInitialPiecePositions()
    }
    
    mutating func setInitialPiecePositions() {
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
}
    

    //we then need to change initialGameState function to have this new address system instead of the string addresses we use now
    //seperate from how we store where the pieces are in a way that is iterable, the game state should also store information such as whose turn it is, "white" or "black", or if the game is "ongoing" or "ended". we save all of this information in a file so that it can be stored on device for a single player game save, or on a server so that we can implement multiplayer, and one central locations both devices can pull the game state from.
    //finally, we need to change func placePieces in the other file GameScene and make it so that is can understand our new datastructure, and put a piece that is stored in any [column_index][row_index] to the hexagon it represents. if there is a white pawn at ["e"][2] (how we store the gamestate in a way that is iterable) it should put a white pawn at hexagon "e2" (the title/name of the proper hexagon) note that whatever data structure we use to store game state information, it should never change the titles of the individual hexagons as initialized in GameScene's generateHexTiles function.
    //you can also look how I implemented this in my javascript code, although it may be hard to understand. basically, I created the board and gave every hexagon a name. then, i create a data structure that stores all of the pieces and a rule set that defines how the pieces can move around in the data set. code does not understand what the board nor can it visually look at the board like humans can. all the rules do is define how the pieces can move around in the data structure, and when its time to place the pieces, i have a function that looks at the game state, (pieces stored at [column_index][row_index] values) and then places those pieces at their respective hexagons, which are seen as strings such "e4". in the javascript code i have a converter function that converts from [column_index][row_index] to string so that the hexagons can be addressable. sorry if this is confusing or repetitive.

//we can kind of ignore these two functions for now, might modify later
//rn is saves the game state in a bulky format, it stores the dictionary struct gamestate
//before launch we should have it convert the game state to algebraic chess notation, then save that in a json file or whatever
//this could cut down the game file save by like 10x
//would also need to change the load game state file to accept algebraic notation from the save file
//can do later though https://en.wikipedia.org/wiki/Algebraic_notation_(chess)
func saveGameState(_ gameState: GameState, to filename: String) {
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

func loadGameState(from filename: String) -> GameState? {
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


/*
func initialGameState() -> GameState {//need to change how we initialize the game state. look above under the struct for my notes on how to do this
    return GameState(pieces: [
        "b7": "black_pawn",
        "c7": "black_pawn",
        "d7": "black_pawn",
        "e7": "black_pawn",
        "f7": "black_pawn",
        "g7": "black_pawn",
        "h7": "black_pawn",
        "i7": "black_pawn",
        "k7": "black_pawn",
        "b1": "white_pawn",
        "c2": "white_pawn",
        "d3": "white_pawn",
        "e4": "white_pawn",
        "f5": "white_pawn",
        "g4": "white_pawn",
        "h3": "white_pawn",
        "i2": "white_pawn",
        "k1": "white_pawn",
        "c8": "black_rook",
        "i8": "black_rook",
        "d9": "black_knight",
        "e10": "black_queen",
        "f11": "black_bishop",
        "f10": "black_bishop",
        "f9": "black_bishop",
        "g10": "black_king",
        "h9": "black_knight",
        "c1": "white_rook",
        "d1": "white_knight",
        "e1": "white_queen",
        "f1": "white_bishop",
        "f2": "white_bishop",
        "f3": "white_bishop",
        "g1": "white_king",
        "h1": "white_knight",
        "i1": "white_rook",
    ])
}
*/
