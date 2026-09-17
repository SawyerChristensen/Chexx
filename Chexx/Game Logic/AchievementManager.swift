//
//  AchievementManager.swift
//  Chexx
//
//  Created by Sawyer Christensen on 1/2/25.
//

import Foundation

struct Achievement: Identifiable, Codable {
    let id: String          // "hex_machina"
    var title: String {     // "Hex Machina"
        NSLocalizedString("ach_\(id)_title", comment: "")
    }
    var description: String {   // "Checkmate the CPU"
        NSLocalizedString("ach_\(id)_description", comment: "")
    }
    var isUnlocked: Bool    // false by default; set to true when unlocked
}

import SwiftUI
import Firebase
import FirebaseAuth

class AchievementManager: ObservableObject {
    static let shared = AchievementManager()
    
    @Published var achievements: [Achievement] = [
            Achievement(id: "hexceptional_win",
                        //title: "Hexceptional Win!",
                        //description: "Win your first game",
                        isUnlocked: false),
            Achievement(id: "hex_machina",
                        //title: "Hex Machina",
                        //description: "Checkmate the CPU",
                        isUnlocked: false),
            Achievement(id: "hextra_power",
                        //title: "Hextra Power",
                        //description: "Promote a pawn for the first time",
                        isUnlocked: false),
            Achievement(id: "hexceeded_hexpectations",
                        //title: "Hexceeded Hexpectations",
                        //description: "Win a joined game",
                        isUnlocked: false),
            Achievement(id: "friendly_hexchange",
                        //title: "Friendly Hexchange",
                        //description: "Have a player join a game you created",
                        isUnlocked: false),
            Achievement(id: "hexcalibur",
                        //title: "Hexcalibur",
                        //description: "Underpromote a pawn to a knight",
                        isUnlocked: false),
            Achievement(id: "hexecutioner",
                        //title: "Hexecutioner",
                        //description: "Checkmate after capturing all enemy pieces",
                        isUnlocked: false),
            Achievement(id: "hexpedition",
                        //title: "Hexpedition",
                        //description: "Move your king to the opposing king's starting position",
                        isUnlocked: false),
            Achievement(id: "hextreme_measures",
                        //title: "Hextreme Measures",
                        //description: "Checkmate using your own king",
                        isUnlocked: false),
            Achievement(id: "tactical_hexcellence",
                        //title: "Tactical Hexcellence",
                        //description: "Checkmate without losing any pieces",
                        isUnlocked: false),
            Achievement(id: "hexclusion_zone",
                        //title: "Hexclusion Zone",
                        //description: "Deliver a smothered mate",
                        isUnlocked: false),
            Achievement(id: "un_hexciting_finish",
                        //title: "Un-Hexciting Finish",
                        //description: "Deliver a stalemate",
                        isUnlocked: false),
            Achievement(id: "hexceptional_morale",
                        //title: "Hexceptional Morale",
                        //description: "Promote 3 pawns in a single game",
                        isUnlocked: false),
            Achievement(id: "great_hexcape",
                        //title: "The Great Hexcape",
                        //description: "Checkmate after being put in check 3 times",
                        isUnlocked: false),
            Achievement(id: "hexplorer",
                        //title: "Hexplorer",
                        //description: "Visit every tile in a single game",
                        isUnlocked: false),
            Achievement(id: "hexpect_the_unexpected",
                        //title: "Hexpect the Unexpected",
                        //description: "Open by moving your king",
                        isUnlocked: false),
            Achievement(id: "hexhausted",
                        //title: "Hexhausted",
                        //description: "Have a game last over 100 turns",
                        isUnlocked: false),
            Achievement(id: "hexathon",
                        //title: "Hexathon",
                        //description: "Win 26 games",
                        isUnlocked: false),
            Achievement(id: "hexperimenter",
                        //title: "Hexperimenter",
                        //description: "Win with 10 different openings",
                        isUnlocked: false),
            Achievement(id: "seasoned_hexpert",
                        //title: "Seasoned Hexpert",
                        //description: "Complete all other achievements",
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

                // Restore cross-game progress after a reinstall. Merged rather than overwritten —
                // take whichever side is further along, so a local tally earned while offline
                // isn't thrown away by a staler remote copy.
                if let progress = data["achievementProgress"] as? [String: Any] {
                    if let remoteWins = progress["totalWins"] as? Int, remoteWins > self.totalWins {
                        UserDefaults.standard.set(remoteWins, forKey: self.winCountKey)
                    }
                    if let remoteOpenings = progress["winningOpenings"] as? [String] {
                        let merged = self.winningOpenings.union(remoteOpenings)
                        UserDefaults.standard.set(Array(merged), forKey: self.winningOpeningsKey)
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

        // This unlock may have been the last one outstanding. Safe to call unconditionally: the
        // early return at the top of this function makes a repeat unlock a no-op, so the mutual
        // recursion between these two bottoms out immediately.
        if id != "seasoned_hexpert" {
            unlockSeasonedHexpertIfEarned()
        }
    }
    
    // MARK: - Cross-game progress
    //
    // Hexathon and Hexperimenter count across games, so unlike everything else here they need a
    // running tally rather than a one-shot flag. Stored in UserDefaults for immediacy and mirrored
    // to Firestore so a reinstall doesn't wipe 25 wins' worth of progress.
    //
    // NOTE: the Firestore mirror writes an `achievementProgress` map, which had to be added to the
    // `onlyChangedFields` whitelist in firestore.rules. Until those rules are deployed the write is
    // rejected and only the local tally advances — achievements still unlock, they just stop
    // surviving a reinstall.

    private let winCountKey = "achievement_total_wins"
    private let winningOpeningsKey = "achievement_winning_openings"

    /// Threshold constants, kept next to the logic so the numbers in the achievement descriptions
    /// and the code can't drift apart.
    private static let hexathonWinTarget = 26
    private static let hexperimenterOpeningTarget = 10

    var totalWins: Int {
        UserDefaults.standard.integer(forKey: winCountKey)
    }

    var winningOpenings: Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: winningOpeningsKey) ?? [])
    }

    /// Call once per game the local player wins. `openingKey` is that player's own first move
    /// (`GameState.openingKey(for:)`); pass nil when it isn't known.
    func recordWin(openingKey: String?) {
        let wins = totalWins + 1
        UserDefaults.standard.set(wins, forKey: winCountKey)

        var openings = winningOpenings
        if let openingKey {
            openings.insert(openingKey)
            UserDefaults.standard.set(Array(openings), forKey: winningOpeningsKey)
        }

        if wins >= AchievementManager.hexathonWinTarget {
            unlockAchievement(withID: "hexathon")
            GameCenterManager.shared.reportAchievement(identifier: "Hexathon")
        }

        if openings.count >= AchievementManager.hexperimenterOpeningTarget {
            unlockAchievement(withID: "hexperimenter")
            GameCenterManager.shared.reportAchievement(identifier: "Hexperimenter")
        }

        syncProgressToFirestore(wins: wins, openings: openings)
    }

    private func syncProgressToFirestore(wins: Int, openings: Set<String>) {
        Firestore.firestore()
            .collection("users")
            .document(currentUserId)
            .updateData([
                "achievementProgress.totalWins": wins,
                "achievementProgress.winningOpenings": Array(openings)
            ]) { error in
                if let error = error {
                    print("Error syncing achievement progress: \(error.localizedDescription)")
                }
            }
    }

    /// Unlocks Seasoned Hexpert once every *other* achievement is unlocked. Called after each
    /// unlock; the `id != seasonedHexpertID` filter is what stops it from counting itself and
    /// deadlocking (it can never be the last one still locked).
    private func unlockSeasonedHexpertIfEarned() {
        let seasonedHexpertID = "seasoned_hexpert"
        let everythingElseUnlocked = achievements
            .filter { $0.id != seasonedHexpertID }
            .allSatisfy { $0.isUnlocked }

        guard everythingElseUnlocked else { return }
        unlockAchievement(withID: seasonedHexpertID)
        GameCenterManager.shared.reportAchievement(identifier: "SeasonedHexpert")
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
        UserDefaults.standard.removeObject(forKey: winCountKey)
        UserDefaults.standard.removeObject(forKey: winningOpeningsKey)
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
