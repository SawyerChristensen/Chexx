//
//  SettingsView.swift
//  Chexx
//
//  Created by Sawyer Christensen on 7/15/24.
//

import SwiftUI
import UserNotifications

struct SettingsWindow: View {
    @Environment(\.colorScheme) var colorScheme // Detecting the current color scheme
    @AppStorage("highlightEnabled") private var highlightEnabled = true
    @AppStorage("backgroundMusicEnabled") private var backgroundMusicEnabled = true
    @AppStorage("soundEffectsEnabled") private var soundEffectsEnabled = true
    @AppStorage("lowMotionEnabled") private var lowMotionEnabled = false
    @AppStorage("playerTurnNotifEnabled") private var playerTurnNotifEnabled = false
    @AppStorage("hasEnteredOnlineGame") private var hasEnteredOnlineGame = false

    @Environment(\.presentationMode) var presentationMode // to dismiss the view

    var body: some View {
        ZStack {
            // semi-transparent background that dismisses the view when tapped
            Color.white.opacity(0.0001) //annoyingly, I can't seem to get this to be 100% clear or else it breaks
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    presentationMode.wrappedValue.dismiss()}
            
            VStack {
                //WaveText(text: "Settings", fontSize: 39)
                Text("Settings")
                    .font(.system(size: 39, weight: .semibold, design: .serif))
                    .padding()

                Toggle("Show Legal Moves", isOn: $highlightEnabled) //note: toggle does not scale with font
                    .frame(maxWidth: 355)
                    .font(.system(size: 24, weight: .medium, design: .serif))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    //.padding(.bottom, 2)

                Toggle("Background Music", isOn: $backgroundMusicEnabled)
                    .frame(maxWidth: 355)
                    .font(.system(size: 24, weight: .medium, design: .serif))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    //.padding(.bottom, 2)

                Toggle("Sound Effects", isOn: $soundEffectsEnabled)
                    .frame(maxWidth: 355)
                    .font(.system(size: 24, weight: .medium, design: .serif))
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                Toggle("Low Motion", isOn: $lowMotionEnabled)
                    .frame(maxWidth: 355)
                    .font(.system(size: 24, weight: .medium, design: .serif))
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                Toggle("Player Turn Notification", isOn: $playerTurnNotifEnabled)
                    .frame(maxWidth: 355)
                    .font(.system(size: 24, weight: .medium, design: .serif))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .disabled(!hasEnteredOnlineGame)
                    .onChange(of: playerTurnNotifEnabled) { _, newValue in
                        guard newValue else { return }
                        NotificationManager.requestAuthorization { granted in
                            if !granted {
                                playerTurnNotifEnabled = false
                            }
                        }
                    }
                if !hasEnteredOnlineGame {
                    Text("Available after your first online game")
                        .font(.system(size: 18, weight: .regular, design: .serif))
                        .foregroundColor(.secondary)
                }
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Close")
                        .font(.system(size: 28, weight: .semibold, design: .serif))
                        .padding()
                        .frame(minWidth: 189, maxHeight: 47)
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
        .onAppear {
            guard playerTurnNotifEnabled else { return }
            NotificationManager.authorizationStatus { status in
                if status == .denied {
                    playerTurnNotifEnabled = false
                }
            }
        }
    }
}
/*
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}*/

