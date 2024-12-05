//
//  MultiplayerManager.swift
//  Chexx
//
//  Created by Sawyer Christensen on 11/17/24.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class MultiplayerManager {
    static let shared = MultiplayerManager()
    
    private let db = Firestore.firestore()
    private var gameListener: ListenerRegistration?
    
    var gameId: String?
    var currentUserId: String
    var opponentId: String?
    var playerColor: String = ""
    var opponentColor: String = ""
    
    private init() {
        currentUserId = Auth.auth().currentUser?.uid ?? UUID().uuidString
    }
    
    func generateGameCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0..<6).compactMap { _ in letters.randomElement() })
    }
    
    func createGame(completion: @escaping (String?) -> Void) {
        let maxAttempts = 5 // Maximum number of attempts to avoid infinite loops

        func tryCreateGame(attemptsLeft: Int) {
            guard attemptsLeft > 0 else {
                print("Failed to generate a unique game code after multiple attempts.")
                completion(nil)
                return
            }

            let gameId = generateGameCode()
            let gameRef = db.collection("games").document(gameId)

            self.playerColor = "black" // Creator of the game is black
            self.opponentColor = "white" // Invited opponent makes the first move

            let gameData: [String: Any] = [
                "player1Id": currentUserId,
                "player1Color": self.playerColor,
                "hexPgn": [], // Start with an empty HexPgn array
                "status": "waiting",
                "lastUpdated": FieldValue.serverTimestamp()
            ]

            // Check if a game with this ID already exists
            gameRef.getDocument { (document, error) in
                if let error = error {
                    print("Error checking for existing game ID: \(error)")
                    completion(nil)
                } else if let document = document, document.exists {
                    // Game ID already exists, try again
                    tryCreateGame(attemptsLeft: attemptsLeft - 1)
                } else {
                    // Game ID is unique, create the game
                    gameRef.setData(gameData) { error in
                        DispatchQueue.main.async {
                            if let error = error {
                                print("Error creating game: \(error)")
                                completion(nil)
                            } else {
                                self.gameId = gameId
                                completion(gameId)
                            }
                        }
                    }
                }
            }
        }

        tryCreateGame(attemptsLeft: maxAttempts) // with 308 million combinations possible with 6 letters, chances are extremely unlikely there will be any collisions anyway
    }

    
    // Join an existing game
    func joinGame(gameId: String, completion: @escaping (Bool) -> Void) {
        let gameRef = db.collection("games").document(gameId)
        gameRef.getDocument { snapshot, error in
            if let error = error {
                print("Error joining game: \(error)")
                completion(false)
                return
            }
            guard let data = snapshot?.data() else {
                print("Game not found")
                completion(false)
                return
            }
            /*if let player2Id = data["player2Id"] as? String {
                print("Game already has two players")
                completion(false)
                return
            }*/
            gameRef.updateData([
                "player2Id": self.currentUserId,
                "player2Color": self.playerColor,
                "status": "in-progress",
                "lastUpdated": FieldValue.serverTimestamp()
            ]) { error in
                if let error = error {
                    print("Error updating game: \(error)")
                    completion(false)
                } else {
                    self.gameId = gameId
                    if let player1Id = data["player1Id"] as? String {
                        self.opponentId = player1Id
                    }
                    completion(true)
                }
            }
        }
    }
    
    // Listen for HexPgn updates
    func startListeningForMoves(hexPgnUpdated: @escaping ([UInt8]) -> Void) {
        guard let gameId = gameId else { return }
        let gameRef = db.collection("games").document(gameId)
        gameListener = gameRef.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error listening for moves: \(error)")
                return
            }
            guard let data = snapshot?.data() else { return }
            if let hexPgnData = data["hexPgn"] as? [Int] {
                // Convert [Int] to [UInt8]
                let hexPgn = hexPgnData.map { UInt8($0) }
                hexPgnUpdated(hexPgn)
            }
        }
    }
    
    // Send move by updating HexPgn
    func sendMove(hexPgn: [UInt8], completion: ((Error?) -> Void)? = nil) {
        print("sendMove: ", hexPgn)
        guard let gameId = gameId else { return }
        let gameRef = db.collection("games").document(gameId)
        // Convert [UInt8] to [Int] because Firestore doesn't support UInt8 directly
        let hexPgnData = hexPgn.map { Int($0) }
        gameRef.updateData([
            "hexPgn": hexPgnData,
            "lastUpdated": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("Error sending move: \(error)")
            }
            completion?(error)
        }
    }
    
    // Remove listener when done
    func stopListening() {
        gameListener?.remove()
    }
}
