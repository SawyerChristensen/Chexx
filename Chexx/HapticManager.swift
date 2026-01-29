//
//  AppHelpers.swift
//  Chexx
//
//  Created by Sawyer Christensen on 1/21/26.
//

import UIKit

struct HapticManager {
    static func playImpact(style: UIImpactFeedbackGenerator.FeedbackStyle) { //standard feedback (like if a piece is placed down)
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    static func playNotification(type: UINotificationFeedbackGenerator.FeedbackType) { //can be used to alert the user to an invalid move
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
