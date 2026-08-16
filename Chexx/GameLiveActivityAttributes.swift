//
//  GameLiveActivityAttributes.swift
//  Chexx
//

import Foundation

// Shared model describing the Live Activity shown on the Lock Screen / Dynamic
// Island for an in-progress online game. The board-preview UI that renders this
// content lives in a widget extension, added separately.
//
// ActivityKit's `Activity`/`ActivityAttributes` are unavailable on both Mac
// Catalyst and native macOS, so this type (and its consumers) only exist on
// true iOS/iPadOS.
#if os(iOS) && !targetEnvironment(macCatalyst)
import ActivityKit

struct GameLiveActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var opponentName: String
        var moveDescription: String
        var lastUpdated: Date
    }

    var gameId: String
}
#endif
