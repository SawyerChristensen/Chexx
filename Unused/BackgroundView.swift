//
//  BackgroundView.swift
//  Chexx
//
//  Created by Sawyer Christensen on 7/15/24.
//

import SwiftUI

struct BackgroundView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Group {
            if colorScheme == .dark {
                darkModeBackground()
            } else {
                lightModeBackground()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }

    // Background for light mode
    func lightModeBackground() -> some View {
        ZStack {
            Image("marble_white")
                .resizable()
                .scaledToFill()
                //.rotationEffect(.degrees(180))
            Color.white.opacity(0.8) // Adjust the opacity as needed
        }
    }

    // Background for dark mode
    func darkModeBackground() -> some View {
        ZStack {
            Image("marble_black")
                .resizable()
                .scaledToFill()
                //.rotationEffect(.degrees(180))
            Color.black.opacity(0.9) // Adjust the opacity as needed
        }
    }
}

struct BackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundView()
    }
}
