//
//  PlatformColor.swift
//  Chexx
//

import SwiftUI
#if canImport(UIKit)
import UIKit
public typealias PlatformFont = UIFont
public typealias PlatformFontDescriptor = UIFontDescriptor
#elseif os(macOS)
import AppKit
public typealias PlatformFont = NSFont
public typealias PlatformFontDescriptor = NSFontDescriptor
#endif

extension View {
    /// `.hoverEffect()` (pointer/trackpad hover feedback) is UIKit-only —
    /// available on iOS and Mac Catalyst, but not native macOS. These call
    /// sites are all custom-shaped `Button` labels (hexagon buttons etc.),
    /// not standard AppKit controls, so they get no automatic hover
    /// highlighting on native macOS either — `NativeMacHoverEffect` below
    /// gives them an explicit `onHover`-driven highlight there instead.
    @ViewBuilder
    func crossPlatformHoverEffect() -> some View {
        #if canImport(UIKit)
        self.hoverEffect()
        #else
        self.modifier(NativeMacHoverEffect())
        #endif
    }

    /// `.textInputAutocapitalization(_:)` only applies to UIKit's on-screen
    /// keyboard — the `TextInputAutocapitalization` type itself doesn't exist
    /// on native macOS, so this is a no-op there.
    @ViewBuilder
    func crossPlatformTextInputAutocapitalization(_ autocapitalization: PlatformTextInputAutocapitalization?) -> some View {
        #if canImport(UIKit)
        self.textInputAutocapitalization(autocapitalization?.uiKitValue)
        #else
        self
        #endif
    }

    /// `.keyboardType(_:)` only applies to UIKit's on-screen keyboard — there's
    /// no on-screen keyboard (or `UIKeyboardType`) on native macOS, so this is
    /// a no-op there.
    @ViewBuilder
    func crossPlatformASCIICapableKeyboard() -> some View {
        #if canImport(UIKit)
        self.keyboardType(.asciiCapable)
        #else
        self
        #endif
    }

    /// `.fullScreenCover(isPresented:content:)` is unavailable on native macOS
    /// (there's no modal concept that covers the whole screen there) — falls
    /// back to `.sheet(isPresented:content:)`, AppKit's equivalent modal
    /// presentation.
    @ViewBuilder
    func crossPlatformFullScreenCover<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        #if canImport(UIKit)
        self.fullScreenCover(isPresented: isPresented, content: content)
        #else
        self.sheet(isPresented: isPresented, content: content)
        #endif
    }
}

/// Cross-platform stand-in for SwiftUI's `TextInputAutocapitalization`, which
/// isn't available on native macOS.
enum PlatformTextInputAutocapitalization {
    case never
    case words
    case sentences
    case characters

    #if canImport(UIKit)
    var uiKitValue: TextInputAutocapitalization {
        switch self {
        case .never: return .never
        case .words: return .words
        case .sentences: return .sentences
        case .characters: return .characters
        }
    }
    #endif
}

#if os(macOS)
/// Pointer-hover highlight for native macOS, standing in for `.hoverEffect()`
/// on the app's custom-shaped buttons (which get no automatic AppKit hover
/// styling since they aren't standard controls).
private struct NativeMacHoverEffect: ViewModifier {
    @State private var isHovering = false

    func body(content: Content) -> some View {
        content
            .brightness(isHovering ? -0.06 : 0)
            .scaleEffect(isHovering ? 1.03 : 1.0)
            .animation(.easeOut(duration: 0.12), value: isHovering)
            .onHover { isHovering = $0 }
    }
}
#endif

extension ToolbarItemPlacement {
    /// Cross-platform equivalent of `.navigationBarLeading`, which is
    /// UIKit-only (iOS/tvOS/watchOS). `.navigation` is AppKit's leading-edge
    /// navigation item placement (e.g. a Back button) on native macOS.
    static var platformLeading: ToolbarItemPlacement {
        #if canImport(UIKit)
        .navigationBarLeading
        #else
        .navigation
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

    /// Cross-platform approximation of `UIColor.systemGray4`.
    static var platformSystemGray4: Color {
        #if canImport(UIKit)
        Color(UIColor.systemGray4)
        #elseif os(macOS)
        Color(NSColor.tertiaryLabelColor)
        #endif
    }
}
