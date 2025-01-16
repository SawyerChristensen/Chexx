//
//  GameOverView.swift
//  Chexx
//
//  Created by Sawyer Christensen on 1/16/25.
//

import SwiftUI

struct GameOverView: View {
    var winner: String
    var method: String
    var completion: (String) -> Void //why do we need this?
    
    @AppStorage("backgroundMusicEnabled") private var backgroundMusicEnabled = true
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            let screenWidth = geometry.size.width
            //let maxScreenDimension = max(screenHeight, screenWidth)
            
            ZStack {
                Color.black.opacity(0.0001) //annoyingly cant get this to be completely clear
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        presentationMode.wrappedValue.dismiss()}
                
                //the visible card
                VStack() {
                    
                    WaveText(text: "Game Over!", fontSize: screenHeight / 20) //should adapt later!
                        .padding(.bottom, 5)
                    
                    Text("\(winner.prefix(1).uppercased() + winner.dropFirst().lowercased()) wins by \(method)!")
                        .font(.system(size: screenHeight / 36, weight: .semibold, design: .serif))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 5)
                    
                    Button(action: {
                        completion("viewBoard")
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("View Board")
                            .font(.system(size: screenHeight / 26, weight: .bold, design: .serif))
                            .padding()
                            .frame(width: screenHeight / 3.66, height: screenHeight / 18)
                            .background(Color.accentColor)
                            .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                            .clipShape(HexagonEdgeRectangleShape())
                    }
                    .padding(5)
                    
                    Button(action: {
                        completion("rematch")
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Rematch")
                            .font(.system(size: screenHeight / 26, weight: .bold, design: .serif))
                            .padding()
                            .frame(width: screenHeight / 4.5, height: screenHeight / 18)
                            .background(Color.accentColor)
                            .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                            .clipShape(HexagonEdgeRectangleShape())
                    }
                    .padding(5)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(15)
                .shadow(radius: 10)
                .padding(.horizontal, 40)
            }
        }
    }
}
