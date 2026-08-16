//
//  AppHelpers.swift
//  Chexx
//
//  Created by Sawyer Christensen on 1/21/26.
//

#if canImport(UIKit)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct HapticManager {
    // Platform-agnostic mirrors of UIKit's feedback enums, since UIImpactFeedbackGenerator/
    // UINotificationFeedbackGenerator don't exist on native macOS (only under Mac Catalyst).
    enum ImpactStyle {
        case light, medium, heavy, soft, rigid
    }

    enum NotificationType {
        case success, warning, error
    }

    static func playImpact(style: ImpactStyle) { //standard feedback (like if a piece is placed down)
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: style.uiKitStyle)
        generator.prepare()
        generator.impactOccurred()
        #elseif os(macOS)
        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
        #endif
    }

    static func playNotification(type: NotificationType) { //can be used to alert the user to an invalid move
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type.uiKitType)
        #elseif os(macOS)
        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
        #endif
    }
}

#if canImport(UIKit)
private extension HapticManager.ImpactStyle {
    var uiKitStyle: UIImpactFeedbackGenerator.FeedbackStyle {
        switch self {
        case .light: return .light
        case .medium: return .medium
        case .heavy: return .heavy
        case .soft: return .soft
        case .rigid: return .rigid
        }
    }
}

private extension HapticManager.NotificationType {
    var uiKitType: UINotificationFeedbackGenerator.FeedbackType {
        switch self {
        case .success: return .success
        case .warning: return .warning
        case .error: return .error
        }
    }
}
#endif
