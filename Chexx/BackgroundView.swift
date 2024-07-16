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
        Image("marble_white")
            .resizable()
            .scaledToFill()
    }

    // Background for dark mode
    func darkModeBackground() -> some View {
        Image("marble_black")
            .resizable()
            .scaledToFill()
    }
}

struct BackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundView()
    }
}
