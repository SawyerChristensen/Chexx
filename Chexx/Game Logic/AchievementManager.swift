//
//  AchievementManager.swift
//  Chexx
//
//  Created by Sawyer Christensen on 1/2/25.
//

import Foundation

struct Achievement: Identifiable, Codable {
    let id: String          // "hex_machina"
    let title: String       // "Hex Machina"
    let description: String // "Checkmate the CPU"
    var isUnlocked: Bool    // false by default; set to true when unlocked
}

import SwiftUI
import Firebase
import FirebaseAuth

class AchievementManager: ObservableObject {
    static let shared = AchievementManager()
    
    @Published var achievements: [Achievement] = [
            Achievement(id: "hex_machina",
                        title: "Hex Machina",
                        description: "Checkmate the CPU",
                        isUnlocked: false),
            Achievement(id: "hextra_power",
                        title: "Hextra Power",
                        description: "Promote a pawn for the first time",
                        isUnlocked: false),
            Achievement(id: "hexceeded_hexpectations",
                        title: "Hexceeded Hexpectations",
                        description: "Win a joined game",
                        isUnlocked: false),
            Achievement(id: "friendly_hexchange",
                        title: "Friendly Hexchange",
                        description: "Have a player join a game you created",
                        isUnlocked: false),
            Achievement(id: "hexcalibur",
                        title: "Hexcalibur",
                        description: "Underpromote a pawn to a knight",
                        isUnlocked: false),
            Achievement(id: "hexecutioner",
                        title: "Hexecutioner",
                        description: "Checkmate after capturing all enemy pieces",
                        isUnlocked: false),
            Achievement(id: "hexpedition",
                        title: "Hexpedition",
                        description: "Move your king to the opposing king's starting position",
                        isUnlocked: false),
            Achievement(id: "hextreme_measures",
                        title: "Hextreme Measures",
                        description: "Checkmate using your own king",
                        isUnlocked: false),
        ]

    private let currentUserId: String
    
    private init() {
        currentUserId = Auth.auth().currentUser?.uid ?? UUID().uuidString
    }
    
    // Firestore (Load)
    func loadUserAchievements() {
        let userDocRef = Firestore.firestore()
            .collection("users")
            .document(currentUserId)
        
        userDocRef.getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let storedAchievements = data["achievements"] as? [String: Bool] {
                
                for (id, isUnlocked) in storedAchievements {
                    if let index = self.achievements.firstIndex(where: { $0.id == id }) {
                        self.achievements[index].isUnlocked = isUnlocked
                    }
                }
            } else {
                print("Error loading achievements: \(error?.localizedDescription ?? "Unknown error")")
            }
            //completion()
        }
    }
    
    // Firestore (Save)
    func unlockAchievement(withID id: String) {
        // 1. Update local array
        guard let index = achievements.firstIndex(where: { $0.id == id }) else { return }
        if achievements[index].isUnlocked == false {
            achievements[index].isUnlocked = true
        } else {
            return // Already unlocked, do nothing
        }
        
        // 2. Update Firestore
        let userDocRef = Firestore.firestore()
            .collection("users")
            .document(currentUserId)
        
        // "achievements" is a dictionary field in the user's document
        userDocRef.updateData(["achievements.\(id)": true]) { error in
            if let error = error {
                print("Error updating achievement: \(error.localizedDescription)")
            } else {
                print("Achievement \(id) updated successfully in Firestore.")
            }
        }
    }
    
    // starter helper methods for debugging
    func checkConditionForHexMachina(isCPUOpponent: Bool, didWinGame: Bool) {
        // If player beat the CPU
        if isCPUOpponent && didWinGame {
            unlockAchievement(withID: "hex_machina")
        }
    }
    
    func checkConditionForHexcalibur(promotedPiece: String) {
        // If user underpromoted to a knight
        if promotedPiece.lowercased() == "knight" {
            unlockAchievement(withID: "hexcalibur")
        }
    }

}
