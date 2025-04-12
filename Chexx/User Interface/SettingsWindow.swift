//
//  SettingsView.swift
//  Chexx
//
//  Created by Sawyer Christensen on 7/15/24.
//

import SwiftUI

struct SettingsWindow: View {
    let screenHeight: CGFloat //built off of 720 for initial iphone 15 pro test
    @Environment(\.colorScheme) var colorScheme // Detecting the current color scheme
    @AppStorage("highlightEnabled") private var highlightEnabled = true
    @AppStorage("backgroundMusicEnabled") private var backgroundMusicEnabled = true
    @AppStorage("soundEffectsEnabled") private var soundEffectsEnabled = true
    @AppStorage("lowMotionEnabled") private var lowMotionEnabled = false
    //@AppStorage("playerTurnNotifEnabled") private var playerTurnNotifEnabled = false
    
    @Environment(\.presentationMode) var presentationMode // to dismiss the view

    var body: some View {
        ZStack {
            // semi-transparent background that dismisses the view when tapped
            Color.white.opacity(0.0001) //annoyingly, I can't seem to get this to be 100% clear or else it breaks
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    presentationMode.wrappedValue.dismiss()}
            
            VStack {
                //WaveText(text: "Settings", fontSize: screenHeight / 24) // Use the custom WaveText view from PromotionView
                Text("Settings")
                    .font(.system(size: screenHeight / 22, weight: .bold, design: .serif))
                    .padding()
                    
                Toggle("Show Legal Moves", isOn: $highlightEnabled) //note: toggle does not scale with font
                    .frame(maxWidth: min(screenHeight / 2.4, 500))
                    .font(.system(size: min(screenHeight / 36, 28), weight: .semibold, design: .serif))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    //.padding(.bottom, 2)
                
                Toggle("Background Music", isOn: $backgroundMusicEnabled)
                    .frame(maxWidth: min(screenHeight / 2.4, 500))
                    .font(.system(size: min(screenHeight / 36, 28), weight: .semibold, design: .serif))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    //.padding(.bottom, 2)
                
                Toggle("Sound Effects", isOn: $soundEffectsEnabled)
                    .frame(maxWidth: min(screenHeight / 2.4, 500))
                    .font(.system(size: min(screenHeight / 36, 28), weight: .semibold, design: .serif))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Toggle("Low Motion", isOn: $lowMotionEnabled)
                    .frame(maxWidth: min(screenHeight / 2.4, 500))
                    .font(.system(size: min(screenHeight / 36, 28), weight: .semibold, design: .serif))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                /*
                Toggle("Player Turn Notification", isOn: $playerTurnNotifEnabled)
                    .frame(maxWidth: min(screenHeight / 2.4, 500))
                    .font(.system(size: min(screenHeight / 36, 28), weight: .semibold, design: .serif))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                */
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Close")
                        .font(.system(size: screenHeight / 30, weight: .bold, design: .serif))
                        .padding()
                        .frame(minWidth: screenHeight / 4.5, maxHeight: screenHeight / 18)
                        .background(Color.accentColor)
                        .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                        .clipShape(HexagonEdgeRectangleShape())
                }
                .padding(.top, 20)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(15)
            .shadow(radius: colorScheme == .dark ? 20 : 100)
            //.scaleEffect(1.2)
        }
    }
}
/*
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(screenHeight: 720)
    }
}*/

