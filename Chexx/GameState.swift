//
//  GameState.swift
//  Chexx
//
//  Created by Sawyer Christensen on 6/29/24.
//

import Foundation

struct GameState: Codable {
    var pieces: [String: String] // first string is the key of the hex tile, ie "e4" second string is the piece ie "white_pawn"
    //this needs to be CHANGED. The first string, (the title, should be addressable. we should be able to iterate through columns and rows like [column_index][row_index]
    //for example, to see what is in the next row over, all we need to do it [column_index][row_index + 1]
    //we then need to change initialGameState function to have this new address system instead of the string addresses we use now
    //seperate from how we store where the pieces are in a way that is iterable, the game state should also store information such as whose turn it is, "white" or "black", or if the game is "ongoing" or "ended". we save all of this information in a file so that it can be stored on device for a single player game save, or on a server so that we can implement multiplayer, and one central locations both devices can pull the game state from.
    //finally, we need to change func placePieces in the other file GameScene and make it so that is can understand our new datastructure, and put a piece that is stored in any [column_index][row_index] to the hexagon it represents. if there is a white pawn at ["e"][2] (how we store the gamestate in a way that is iterable) it should put a white pawn at hexagon "e2" (the title/name of the proper hexagon) note that whatever data structure we use to store game state information, it should never change the titles of the individual hexagons as initialized in GameScene's generateHexTiles function.
    //you can also look how I implemented this in my javascript code, although it may be hard to understand. basically, I created the board and gave every hexagon a name. then, i create a data structure that stores all of the pieces and a rule set that defines how the pieces can move around in the data set. code does not understand what the board nor can it visually look at the board like humans can. all the rules do is define how the pieces can move around in the data structure, and when its time to place the pieces, i have a function that looks at the game state, (pieces stored at [column_index][row_index] values) and then places those pieces at their respective hexagons, which are seen as strings such "e4". in the javascript code i have a converter function that converts from [column_index][row_index] to string so that the hexagons can be addressable. sorry if this is confusing or repetitive.
}

//we can kind of ignore these two functions for now, might modify later
//rn is saves the game state in a bulky format, it stores the dictionary struct gamestate
//before launch we should have it convert the game state to algebraic chess notation, then save that in a json file or whatever
//this could cut down the game file save by like 10x
//would also need to change the load game state file to accept algebraic notation from the save file
//can do later though https://en.wikipedia.org/wiki/Algebraic_notation_(chess)
func saveGameState(_ gameState: GameState, to filename: String) {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(gameState) {
        let defaults = UserDefaults.standard
        defaults.set(encoded, forKey: filename)
    }
}

func loadGameState(from filename: String) -> GameState? {
    let defaults = UserDefaults.standard
    if let savedGameState = defaults.object(forKey: filename) as? Data {
        let decoder = JSONDecoder()
        if let loadedGameState = try? decoder.decode(GameState.self, from: savedGameState) {
            return loadedGameState
        }
    }
    return nil
}

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
