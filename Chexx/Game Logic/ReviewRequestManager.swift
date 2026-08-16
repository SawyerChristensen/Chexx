//
//  ReviewRequestManager.swift
//  Chexx
//

import Foundation
import StoreKit
#if canImport(UIKit)
import UIKit
#elseif os(macOS)
import AppKit
#endif

class ReviewRequestManager {
    static let shared = ReviewRequestManager()
    private init() {}

    // AppStore.requestReview(in:) is presented from a UIWindowScene on iOS/Catalyst
    // but from an NSViewController on native macOS.
    #if canImport(UIKit)
    typealias ReviewPresentationContext = UIWindowScene
    #elseif os(macOS)
    typealias ReviewPresentationContext = NSViewController
    #endif

    private let eligibleWinCountKey = "reviewPromptEligibleWinCount"
    private let cpuWinCountKey = "reviewPromptCPUWinCount"
    private let lastRequestDateKey = "reviewPromptLastRequestDate"
    private let winsBetweenPrompts = 5
    private let cpuWinsBeforeFirstPrompt = 2
    private let minDaysBetweenPrompts = 60

    // Call after a multiplayer win, or a CPU win at the CPU's hardest difficulty.
    func requestReviewIfAppropriate(in context: ReviewPresentationContext?) {
        let defaults = UserDefaults.standard

        let winCount = defaults.integer(forKey: eligibleWinCountKey) + 1
        defaults.set(winCount, forKey: eligibleWinCountKey)

        guard winCount % winsBetweenPrompts == 0 else { return }

        requestReview(in: context)
    }

    // Call after any CPU win, regardless of difficulty. Prompts once, on the player's 2nd CPU win.
    func requestReviewAfterCPUWinIfAppropriate(in context: ReviewPresentationContext?) {
        let defaults = UserDefaults.standard

        let winCount = defaults.integer(forKey: cpuWinCountKey) + 1
        defaults.set(winCount, forKey: cpuWinCountKey)

        guard winCount == cpuWinsBeforeFirstPrompt else { return }

        requestReview(in: context)
    }

    private func requestReview(in context: ReviewPresentationContext?) {
        let defaults = UserDefaults.standard

        if let lastRequestDate = defaults.object(forKey: lastRequestDateKey) as? Date {
            let daysSinceLastRequest = Calendar.current.dateComponents([.day], from: lastRequestDate, to: Date()).day ?? 0
            guard daysSinceLastRequest >= minDaysBetweenPrompts else { return }
        }

        guard let context = context else { return }

        defaults.set(Date(), forKey: lastRequestDateKey)
        Task { @MainActor in
            AppStore.requestReview(in: context)
        }
    }
}
