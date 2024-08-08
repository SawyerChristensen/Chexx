//
//  ProfileView.swift
//  Chexx
//
//  Created by Sawyer Christensen on 7/15/24.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.colorScheme) var colorScheme // Detecting the current color scheme

    var body: some View {
        ZStack {
            //BackgroundView()
            VStack {
                Text("*PROFILE CONTENT HERE*")
                // Your settings content goes here
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Profile")
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
