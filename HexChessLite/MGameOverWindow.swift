//
//  GameOverView.swift
//  Chexx
//
//  Created by Sawyer Christensen on 1/16/25.
//

import SwiftUI

struct MessagesGameOverWindow: View {
    var winner: String
    var method: String
    var completion: (String) -> Void //why do we need this?
    
    @AppStorage("backgroundMusicEnabled") private var backgroundMusicEnabled = true
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            //let screenWidth = geometry.size.width
            //let maxScreenDimension = max(screenHeight, screenWidth)
            
            ZStack {
                Color.black.opacity(0.0001) //annoyingly cant get this to be completely clear
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        presentationMode.wrappedValue.dismiss()}
                
                //the visible card
                VStack() {
                    
                    WaveText(text: NSLocalizedString("Game Over!", comment: ""), fontSize: screenHeight / 20) //should adapt later!
                        .padding(.bottom, 5)
                    
                    Text(
                          String(
                            format: NSLocalizedString("%@ wins by %@!", comment: "Game over message: {Winner Color} wins by {Method}!"),
                            NSLocalizedString(winner, comment: "Winner color (white/black)"), //white/black show up as "stale" due to not being directly refereneced, but conditionally referenced here. it is safe to ignore them being "stale" in the localizable file. same with Checkmate/Stalemate:
                            NSLocalizedString(method, comment: "Winning method (Checkmate, etc.)")
                          )
                        )
                        .font(.system(size: screenHeight / 36, weight: .semibold, design: .serif))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 5)
                    
                    Button(action: {
                        completion("viewBoard")
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("View Board")
                            .font(.system(size: screenHeight / 28, weight: .bold, design: .serif))
                            .padding()
                            .frame(minWidth: screenHeight / 3.66, maxHeight: screenHeight / 20)
                            .background(Color.accent)
                            .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                            .clipShape(HexagonEdgeRectangleShape())
                    }
                    .padding(5)
                    
                    Button(action: {
                        completion("rematch")
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Rematch")
                            .font(.system(size: screenHeight / 28, weight: .bold, design: .serif))
                            .padding()
                            .frame(minWidth: screenHeight / 4.5, maxHeight: screenHeight / 20)
                            .background(Color.accent)
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
