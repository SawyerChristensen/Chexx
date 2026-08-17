//
//  GameCenterManager.swift
//  Chexx
//
//  Created by Sawyer Christensen on 3/28/25.
//

import Foundation
import GameKit
#if canImport(UIKit)
import UIKit
#elseif os(macOS)
import AppKit
#endif

class GameCenterManager: NSObject {
    static let shared = GameCenterManager()

    /// The view controller type GameKit uses to present its own UI —
    /// `UIViewController` on iOS/Catalyst, `NSViewController` on native macOS.
    #if canImport(UIKit)
    typealias PresentingViewController = UIViewController
    #elseif os(macOS)
    typealias PresentingViewController = NSViewController
    #endif

    private let localPlayer = GKLocalPlayer.local

    /// Set once `authenticateHandler` has fired at least once (success or failure). Used to
    /// distinguish "not authenticated yet because the async handshake is still in flight" (e.g.
    /// right after launch) from "not authenticated, and we already know that" — callers made
    /// while the handshake is still in flight get retried instead of permanently failing.
    private var hasCompletedInitialAuthenticationAttempt = false
    private var pendingAuthenticationCallbacks: [() -> Void] = []

    private override init() { // Private initializer to enforce singleton usage
        super.init()
    }

    /// - Parameter presentingViewController: The view controller used to present the Game Center login screen if needed.
    func authenticateLocalPlayer(presentingViewController: PresentingViewController?) {
        localPlayer.authenticateHandler = { [weak self] gcAuthVC, error in
            guard let self = self else { return }

            //if let error = error {
                //print("Game Center authentication error: \(error.localizedDescription)")
            //    return
            //}

            if let gcAuthVC = gcAuthVC, let presenter = presentingViewController {
                // Present the Game Center authentication view controller
                #if canImport(UIKit)
                presenter.present(gcAuthVC, animated: true, completion: nil)
                #elseif os(macOS)
                presenter.presentAsSheet(gcAuthVC)
                #endif
            } else if self.localPlayer.isAuthenticated {
                //print("Game Center: Player already authenticated.")
            } else {
                //print("Game Center: Player not authenticated and no login UI available.")
            }

            self.hasCompletedInitialAuthenticationAttempt = true
            let callbacks = self.pendingAuthenticationCallbacks
            self.pendingAuthenticationCallbacks.removeAll()
            callbacks.forEach { $0() }
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
            if error != nil {
                //print("Error reporting achievement \(identifier): \(error.localizedDescription)")
            } else {
                //print("Successfully reported achievement \(identifier).")
            }
        }
    }
    
    /// Loads the Game Center profile image (if available)
    /// - Parameter completion: Called with the image if successful, or nil on failure
    func loadGameCenterProfileImage(completion: @escaping (PlatformImage?) -> Void) {
        guard localPlayer.isAuthenticated else {
            if !hasCompletedInitialAuthenticationAttempt {
                // The async authentication handshake (started at app launch) may still be in
                // flight — retry once it resolves instead of failing permanently.
                pendingAuthenticationCallbacks.append { [weak self] in
                    self?.loadGameCenterProfileImage(completion: completion)
                }
            } else {
                //print("Game Center: Local player not authenticated — can't load profile image.")
                completion(nil)
            }
            return
        }

        localPlayer.loadPhoto(for: .normal) { image, error in
            if error != nil {
                //print("Game Center: Failed to load profile image: \(error.localizedDescription)")
            }
            completion(image)
        }
    }
    
    /// Show the standard Game Center Achievements interface.
    /// - Parameter viewController: The view controller that presents the Game Center view.
    func showAchievements(from viewController: PresentingViewController) {
        guard localPlayer.isAuthenticated else {
            //print("Game Center: Local player is not authenticated, cannot show achievements.")
            return
        }

        let gcVC = GKGameCenterViewController(state: .achievements)
        gcVC.gameCenterDelegate = self
        #if canImport(UIKit)
        viewController.present(gcVC, animated: true, completion: nil)
        #elseif os(macOS)
        viewController.presentAsSheet(gcVC)
        #endif
    }
}

extension GameCenterManager: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        #if canImport(UIKit)
        gameCenterViewController.dismiss(animated: true, completion: nil)
        #elseif os(macOS)
        gameCenterViewController.dismiss(gameCenterViewController)
        #endif
    }
}
