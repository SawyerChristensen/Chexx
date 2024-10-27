//
//  PromotionViewController.swift
//  Chexx
//
//  Created by Sawyer Christensen on 8/8/24.
//

import SwiftUI

struct PromotionViewController: UIViewControllerRepresentable {
    var completion: (String) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        let hostingController = UIHostingController(rootView: PromotionView(completion: completion))
        hostingController.modalPresentationStyle = .overCurrentContext
        hostingController.view.backgroundColor = .clear // Make the background transparent if needed
        return hostingController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {} //might not need this
}
