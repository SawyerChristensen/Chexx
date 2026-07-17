//
//  UIApplication+ActiveScene.swift
//  Chexx
//
//  Created by Sawyer Christensen on 7/16/26.
//

import UIKit

extension UIApplication {
    /// Root view controller of the current foreground-active window scene.
    /// On Mac Catalyst, `connectedScenes` also contains internal helper scenes
    /// (e.g. a NonHostingNSWindowScene), so grabbing `.first` can return the
    /// wrong one and silently break presentation (sign-in sheets, Game Center, etc).
    var activeRootViewController: UIViewController? {
        let activeScene = connectedScenes.first { $0.activationState == .foregroundActive } as? UIWindowScene
        let scene = activeScene ?? connectedScenes.first as? UIWindowScene
        return scene?.windows.first(where: \.isKeyWindow)?.rootViewController ?? scene?.windows.first?.rootViewController
    }
}
