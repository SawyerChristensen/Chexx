//
//  SettingsView.swift
//  Chexx
//
//  Created by Sawyer Christensen on 7/15/24.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme // Detecting the current color scheme
    @AppStorage("highlightEnabled") private var highlightEnabled = true

    var body: some View {
        ZStack {
            //BackgroundView()
            VStack {
                Spacer()
                //Text("*SETTINGS CONTENT HERE*").font(.system(size: 20, weight: .bold, design: .serif))
                HStack {
                    Spacer()
                    
                    Toggle("Enable Highlight", isOn: $highlightEnabled)
                        //.padding()
                        .frame(maxWidth: 300)
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        //.shadow(color: .white, radius: 10, x: 0, y: 0)
                    
                    Spacer()
                }
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
