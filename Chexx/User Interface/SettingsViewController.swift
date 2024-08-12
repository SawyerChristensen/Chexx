//
//  SettingsViewController.swift
//  Chexx
//
//  Created by Sawyer Christensen on 8/11/24.
//

import SwiftUI

struct SettingsViewController: UIViewControllerRepresentable {
    var screenHeight: CGFloat
    var onDismiss: (() -> Void)?
    
    func makeUIViewController(context: Context) -> UIViewController {
        let hostingController = UIHostingController(rootView: SettingsView(screenHeight: screenHeight))
        hostingController.modalPresentationStyle = .overFullScreen
        hostingController.view.backgroundColor = .clear // Make the background transparent
        return hostingController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
