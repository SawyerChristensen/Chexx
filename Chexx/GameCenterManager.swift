//
//  GameCenterManager.swift
//  Chexx
//
//  Created by Sawyer Christensen on 3/28/25.
//

import Foundation
import GameKit

class GameCenterManager: NSObject {
    static let shared = GameCenterManager()
    
    private let localPlayer = GKLocalPlayer.local
    
    private override init() { // Private initializer to enforce singleton usage
        super.init()
    }
    
    /// - Parameter presentingViewController: The UIViewController used to present the Game Center login screen if needed.
    func authenticateLocalPlayer(presentingViewController: UIViewController?) {
        localPlayer.authenticateHandler = { [weak self] gcAuthVC, error in
            guard let self = self else { return }
            
            //if let error = error {
                //print("Game Center authentication error: \(error.localizedDescription)")
            //    return
            //}
            
            if let gcAuthVC = gcAuthVC, let presenter = presentingViewController {
                // Present the Game Center authentication view controller
                presenter.present(gcAuthVC, animated: true, completion: nil)
            } else if self.localPlayer.isAuthenticated {
                //print("Game Center: Player already authenticated.")
            } else {
                //print("Game Center: Player not authenticated and no login UI available.")
            }
        }
    }
    
    /// Report an achievement to Game Center.
    /// - Parameters:
    ///   - identifier: The Achievement ID you configured in App Store Connect.
    ///   - percent: The percentage complete of the achievement (100.0 for “complete”). (set to 100 by default)
    func reportAchievement(identifier: String, percent: Double = 100.0) {
        guard localPlayer.isAuthenticated else {
            //print("Game Center: Local player is not authenticated, cannot report achievement.")
            return
        }
        
        let achievement = GKAchievement(identifier: identifier)
        achievement.percentComplete = percent
        achievement.showsCompletionBanner = true
        
        GKAchievement.report([achievement]) { error in
            if let error = error {
                //print("Error reporting achievement \(identifier): \(error.localizedDescription)")
            } else {
                //print("Successfully reported achievement \(identifier).")
            }
        }
    }
    
    /// Loads the Game Center profile image (if available)
    /// - Parameter completion: Called with the UIImage if successful, or nil on failure
    func loadGameCenterProfileImage(completion: @escaping (UIImage?) -> Void) {
        guard localPlayer.isAuthenticated else {
            //print("Game Center: Local player not authenticated — can't load profile image.")
            completion(nil)
            return
        }
        
        localPlayer.loadPhoto(for: .normal) { image, error in
            if let error = error {
                //print("Game Center: Failed to load profile image: \(error.localizedDescription)")
            }
            completion(image)
        }
    }
    
    /// Show the standard Game Center Achievements interface.
    /// - Parameter viewController: The UIViewController that presents the Game Center view.
    func showAchievements(from viewController: UIViewController) {
        guard localPlayer.isAuthenticated else {
            //print("Game Center: Local player is not authenticated, cannot show achievements.")
            return
        }
        
        let gcVC = GKGameCenterViewController(state: .achievements)
        gcVC.gameCenterDelegate = self
        viewController.present(gcVC, animated: true, completion: nil)
    }
}

extension GameCenterManager: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}
