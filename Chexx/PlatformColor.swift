//
//  PlatformColor.swift
//  Chexx
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension View {
    /// `.hoverEffect()` (pointer/trackpad hover feedback) is UIKit-only —
    /// available on iOS and Mac Catalyst, but not native macOS, where hover
    /// feedback is handled natively by AppKit controls instead.
    @ViewBuilder
    func crossPlatformHoverEffect() -> some View {
        #if canImport(UIKit)
        self.hoverEffect()
        #else
        self
        #endif
    }
}

extension Color {
    /// Cross-platform approximation of `UIColor.systemBackground` — the default
    /// window/sheet background color.
    static var platformSystemBackground: Color {
        #if canImport(UIKit)
        Color(UIColor.systemBackground)
        #elseif os(macOS)
        Color(NSColor.windowBackgroundColor)
        #endif
    }

    /// Cross-platform approximation of `UIColor.systemGray6` — the lightest
    /// system gray, used here for dark-mode button/sheet backgrounds.
    static var platformSystemGray6: Color {
        #if canImport(UIKit)
        Color(UIColor.systemGray6)
        #elseif os(macOS)
        Color(NSColor.controlBackgroundColor)
        #endif
    }

    /// Cross-platform approximation of `UIColor.systemGray5`.
    static var platformSystemGray5: Color {
        #if canImport(UIKit)
        Color(UIColor.systemGray5)
        #elseif os(macOS)
        Color(NSColor.separatorColor)
        #endif
    }
}
