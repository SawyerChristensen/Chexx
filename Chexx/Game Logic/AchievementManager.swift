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
            Achievement(id: "hexceptional_win",
                        title: "Hexceptional Win!",
                        description: "Win your first game",
                        isUnlocked: false),
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
        
        // Load achievements from UserDefaults and update the local array
        for i in 0..<achievements.count {
            let achievementID = achievements[i].id
            // If found in UserDefaults, set isUnlocked
            let isUnlockedLocally = UserDefaults.standard.bool(forKey: achievementID)
            achievements[i].isUnlocked = isUnlockedLocally
        }
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
    
    func unlockAchievement(withID id: String) {
        // Check if the achievement is already unlocked in UserDefaults
        let isAlreadyUnlockedLocally = UserDefaults.standard.bool(forKey: id)
        if isAlreadyUnlockedLocally { //do nothing, its alread unlocked!
            //print("Achievement \(id) is already unlocked locally.")
            return
        }
        
        // Mark it unlocked in the local achievements array
        guard let index = achievements.firstIndex(where: { $0.id == id }) else { return }
        achievements[index].isUnlocked = true
        
        // Save to UserDefaults
        UserDefaults.standard.set(true, forKey: id)
        //print("Achievement \(id) set to unlocked in UserDefaults.")
        
        // Update Firestore
        let userDocRef = Firestore.firestore()
            .collection("users")
            .document(currentUserId)
        
        userDocRef.updateData(["achievements.\(id)": true]) { error in
            if let error = error {
                print("Error updating achievement: \(error.localizedDescription)")
            } else {
                print("Achievement \(id) updated successfully in Firestore.")
            }
        }
    }
    
    func resetLocalAchievements() {
        // Reset all achievements in the local array
        achievements = achievements.map { achievement in
            var updatedAchievement = achievement
            updatedAchievement.isUnlocked = false
            return updatedAchievement
        }
        
        // Remove achievement-related data from UserDefaults
        for achievement in achievements {
            UserDefaults.standard.removeObject(forKey: achievement.id)
        }
    }

/*
    func resetAchievements() {
        // Reset local achievements to locked
        achievements = achievements.map { achievement in
            var updatedAchievement = achievement
            updatedAchievement.isUnlocked = false
            return updatedAchievement
        }
        
        // Update Firestore
        let userDocRef = Firestore.firestore()
            .collection("users")
            .document(currentUserId)
        
        // Create a dictionary with all achievements set to false
        var resetAchievements: [String: Bool] = [:]
        for achievement in achievements {
            resetAchievements[achievement.id] = false
        }
        
        // Write the reset achievements to Firestore
        userDocRef.setData(["achievements": resetAchievements], merge: true) { error in
            if let error = error {
                print("Error resetting achievements: \(error.localizedDescription)")
            } else {
                print("Achievements reset successfully in Firestore.")
            }
        }
    }*/
}
