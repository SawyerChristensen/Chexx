//
//  GameLiveActivityAttributes.swift
//  Chexx
//

import ActivityKit
import Foundation

// Shared model describing the Live Activity shown on the Lock Screen / Dynamic
// Island for an in-progress online game. The board-preview UI that renders this
// content lives in a widget extension, added separately.
struct GameLiveActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var opponentName: String
        var moveDescription: String
        var lastUpdated: Date
    }

    var gameId: String
}
