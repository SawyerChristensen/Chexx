//
//  QuickActionManager.swift
//  Chexx
//
//  Created by Sawyer Christensen on 7/21/26.
//

import Foundation

// Mirrors the UIApplicationShortcutItemType values declared in Info.plist's
// UIApplicationShortcutItems (Home Screen quick actions).
enum QuickAction: String {
    case vsCPU = "com.chexx.quickaction.vsCPU"
    case passAndPlay = "com.chexx.quickaction.passAndPlay"
    case online = "com.chexx.quickaction.online"
}

// Bridges a Home Screen quick action tap (handled in AppDelegate, for both
// cold launch and while already running) to MainMenuView, which consumes and
// clears it once handled.
final class QuickActionManager: ObservableObject {
    static let shared = QuickActionManager()
    private init() {}

    @Published var pendingAction: QuickAction?
}
