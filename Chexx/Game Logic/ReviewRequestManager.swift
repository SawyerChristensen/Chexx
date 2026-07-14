//
//  ReviewRequestManager.swift
//  Chexx
//

import Foundation
import StoreKit
import UIKit

class ReviewRequestManager {
    static let shared = ReviewRequestManager()
    private init() {}

    private let eligibleWinCountKey = "reviewPromptEligibleWinCount"
    private let lastRequestDateKey = "reviewPromptLastRequestDate"
    private let winsBetweenPrompts = 5
    private let minDaysBetweenPrompts = 60

    // Call after a multiplayer win, or a CPU win at the CPU's hardest difficulty.
    func requestReviewIfAppropriate(in scene: UIWindowScene?) {
        let defaults = UserDefaults.standard

        let winCount = defaults.integer(forKey: eligibleWinCountKey) + 1
        defaults.set(winCount, forKey: eligibleWinCountKey)

        guard winCount % winsBetweenPrompts == 0 else { return }

        if let lastRequestDate = defaults.object(forKey: lastRequestDateKey) as? Date {
            let daysSinceLastRequest = Calendar.current.dateComponents([.day], from: lastRequestDate, to: Date()).day ?? 0
            guard daysSinceLastRequest >= minDaysBetweenPrompts else { return }
        }

        guard let scene = scene else { return }

        defaults.set(Date(), forKey: lastRequestDateKey)
        Task { @MainActor in
            AppStore.requestReview(in: scene)
        }
    }
}
