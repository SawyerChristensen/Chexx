//
//  GameState.swift
//  Chexx
//
//  Created by Sawyer Christensen on 6/29/24.
//

import Foundation

struct GameState: Codable {
    var pieces: [String: String] // Dictionary to map hex position to piece name
}

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

func initialGameState() -> GameState {
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
        "h9": "black_bishop",
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
