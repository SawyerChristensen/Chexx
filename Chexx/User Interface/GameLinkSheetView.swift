//
//  GameLinkSheetView.swift
//  Chexx
//
//  Created by Sawyer Christensen on 12/5/24.
//

import SwiftUI

struct GameLinkSheetView: View {
    @Binding var isPresented: Bool
    @Binding var navigateToGameView: Bool
    @Binding var gameLink: String
    @Environment(\.colorScheme) var colorScheme
    var screenHeight: CGFloat

    var body: some View {
        VStack {
            Text("Share this Game ID with your opponent:")
                .font(.title2)
                //.padding()

            if gameLink.isEmpty {
                // Show a loading indicator while gameLink is empty
                ProgressView()
                    .padding()
            } else {
                Text(gameLink)
                    .font(.system(size: 30, weight: .bold, design: .monospaced))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .tracking(3) //spacing in btween letters for better visibility
                    .padding()

                Button(action: {
                    UIPasteboard.general.string = gameLink
                }) {
                    Text("Copy to Clipboard")
                        .underline()
                }
                .underline(true)
                .padding(.bottom, 24)
            }

            Button(action: {
                isPresented = false
                navigateToGameView = true
            }) {
                Text("Start Game →")
                    .font(.system(size: 30, weight: .bold, design: .serif))
                    .frame(width: 240, height: 60)
                    .background(Color.accentColor)
                    .foregroundColor(colorScheme == .dark ? Color(UIColor.systemGray6) : .white)
                    .clipShape(HexagonEdgeRectangleShape())
            }
            .padding()
        }
        .padding()
        .presentationDetents([.medium]) //i dont think this ALWAYS triggers, but it really should
        .presentationDragIndicator(.visible)
    }
}
