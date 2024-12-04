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
    
    // Create a new game
    func createGame(completion: @escaping (String?) -> Void) {
        let gameRef = db.collection("games").document()
        let gameId = gameRef.documentID
        
        self.playerColor = "black" //creator of the game is black
        self.opponentColor = "white" //invited opponent makes the first move
        
        let gameData: [String: Any] = [
            "player1Id": currentUserId,
            "player1Color": self.playerColor,
            "hexPgn": [], // Start with an empty HexPgn array
            "status": "waiting",
            "lastUpdated": FieldValue.serverTimestamp()
        ]
        
        gameRef.setData(gameData) { error in
            if let error = error {
                print("Error creating game: \(error)")
                completion(nil)
            } else {
                self.gameId = gameId
                completion(gameId)
            }
        }
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
