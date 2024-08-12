//
//  SettingsView.swift
//  Chexx
//
//  Created by Sawyer Christensen on 7/15/24.
//

import SwiftUI

struct SettingsView: View {
    let screenHeight: CGFloat //built off of 720 for initial iphone 15 pro test
    @Environment(\.colorScheme) var colorScheme // Detecting the current color scheme
    @AppStorage("highlightEnabled") private var highlightEnabled = true
    //@AppStorage("tabletopRotateTableOnTurn") private var tabletopRotateTableOnTurn = true
    //@AppStorage("tabletopPermRotateBlack") private var tabletopPermRotateBlack = true
    @Environment(\.presentationMode) var presentationMode // to dismiss the view

    var body: some View {
        ZStack {
            // Transparent background that dismisses the view when tapped
            Color.white.opacity(0.0001) // Slightly transparent background
                .edgesIgnoringSafeArea(.all) // Ensures it covers the entire screen, including safe areas
                .onTapGesture {
                    presentationMode.wrappedValue.dismiss()
                }
            VStack {
                WaveText(text: "Settings", fontSize: screenHeight / 24) // Use the custom WaveText view from PromotionView
                    .padding()
                
                VStack {
                    
                    Toggle("Highlight Available Moves", isOn: $highlightEnabled) //note: toggle does not scale with font
                    //.padding()
                        .frame(maxWidth: min(screenHeight / 2.4, 500))
                        .font(.system(size: min(screenHeight / 40, 28), weight: .bold, design: .serif))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    //.shadow(color: .white, radius: 10, x: 0, y: 0)
                    /*
                     Text("Tabletop")
                     .font(.system(size: 36, weight: .bold, design: .serif))
                     .padding(.top)
                     
                     Toggle("Rotate Table on Turn", isOn: $tabletopRotateTableOnTurn) //note: toggle does not scale with font
                     //.padding()
                     .frame(maxWidth: min(screenHeight / 2.4, 500))
                     .font(.system(size: min(screenHeight / 40, 28), weight: .bold, design: .serif))
                     .foregroundColor(colorScheme == .dark ? .white : .black)
                     //.shadow(color: .white, radius: 10, x: 0, y: 0)
                     .padding(.bottom)
                     */
                }
                
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Close")
                        .font(.system(size: screenHeight / 30, weight: .bold, design: .serif))
                        .padding()
                        .frame(width: screenHeight / 4.5, height: screenHeight / 18)
                        .background(Color.accentColor)
                        .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                        .clipShape(HexagonEdgeRectangleShape())
                }
                .padding(.top, 20)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(15)
            .shadow(radius: 100)
            //.shadow(radius: 100)
            //.scaleEffect(1.2)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(screenHeight: 720)
    }
}

