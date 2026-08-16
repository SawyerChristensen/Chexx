//
//  LiveActivityManager.swift
//  Chexx
//

import Foundation

// Owns the ActivityKit lifecycle (start/update/end) for the current game's Live
// Activity. Callers just report game events; the widget extension that renders
// the activity's UI is wired up separately, and move-detection callers are wired
// up separately too.
//
// ActivityKit's `Activity`/`ActivityAuthorizationInfo` are unavailable on both
// Mac Catalyst and native macOS, so start/update/end are no-ops there — callers
// don't need their own platform checks.
#if os(iOS) && !targetEnvironment(macCatalyst)
import ActivityKit

enum LiveActivityManager {
    private static var currentActivity: Activity<GameLiveActivityAttributes>?

    static func start(gameId: String, opponentName: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        end()

        let attributes = GameLiveActivityAttributes(gameId: gameId)
        let initialState = GameLiveActivityAttributes.ContentState(
            opponentName: opponentName,
            moveDescription: "Game started",
            lastUpdated: Date()
        )

        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil)
            )
        } catch {
            print("Failed to start live activity: \(error.localizedDescription)")
        }
    }

    static func update(moveDescription: String) {
        guard let activity = currentActivity else { return }
        let state = GameLiveActivityAttributes.ContentState(
            opponentName: activity.content.state.opponentName,
            moveDescription: moveDescription,
            lastUpdated: Date()
        )
        Task {
            await activity.update(.init(state: state, staleDate: nil))
        }
    }

    static func end() {
        guard let activity = currentActivity else { return }
        currentActivity = nil
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }
}
#else
enum LiveActivityManager {
    static func start(gameId: String, opponentName: String) {}
    static func update(moveDescription: String) {}
    static func end() {}
}
#endif
