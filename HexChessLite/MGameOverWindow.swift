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
    /// Draws have no winner; `winner` is ignored when this is true.
    var isDraw: Bool = false
    var completion: (String) -> Void //why do we need this?
    
    @AppStorage("backgroundMusicEnabled") private var backgroundMusicEnabled = true
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    /// A draw has no winner, so the usual "{colour} wins by {method}" line doesn't apply and a
    /// separate string is needed rather than passing an empty winner.
    private var resultText: String {
        if isDraw {
            return String(
                format: NSLocalizedString("Draw by %@!", comment: "Game over message: Draw by {Method}!"),
                NSLocalizedString(method, comment: "Drawing method (Fifty-Move Rule, Threefold Repetition)")
            )
        }
        return String(
            format: NSLocalizedString("%@ wins by %@!", comment: "Game over message: {Winner Color} wins by {Method}!"),
            NSLocalizedString(winner, comment: "Winner color (white/black)"), //white/black show up as "stale" due to not being directly refereneced, but conditionally referenced here. it is safe to ignore them being "stale" in the localizable file. same with Checkmate/Stalemate:
            NSLocalizedString(method, comment: "Winning method (Checkmate, etc.)")
        )
    }

    // WaveText animates per character and derives its amplitude and natural width from a concrete
    // point size, so it needs a number rather than a text style. It scales itself down to fit, so a
    // long translation is already handled. 34 matches .largeTitle, keeping it in step with the rest.
    private let gameOverTitleFontSize: CGFloat = 34

    // Both buttons previously took different hand-derived minimum widths (screenHeight / 3.66 and
    // / 4.5 — about 230 and 187 points on a typical phone), which made them mismatched for no
    // apparent reason. One shared width keeps the stack tidy at any text length.
    private let gameOverButtonMinWidth: CGFloat = 200

    var body: some View {
        ZStack {
            Color.black.opacity(0.0001) //annoyingly cant get this to be completely clear
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    presentationMode.wrappedValue.dismiss()}
                
            //the visible card
            VStack() {
                    
                WaveText(text: NSLocalizedString("Game Over!", comment: ""), fontSize: gameOverTitleFontSize)
                    .padding(.bottom, 5)
                    
                Text(resultText)
                    .font(.system(.title2, design: .serif).weight(.medium))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 5)
                    
                Button(action: {
                    completion("viewBoard")
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("View Board")
                        .font(.system(.title, design: .serif).weight(.semibold))
                        .padding()
                        .frame(minWidth: gameOverButtonMinWidth)
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
                        .font(.system(.title, design: .serif).weight(.semibold))
                        .padding()
                        .frame(minWidth: gameOverButtonMinWidth)
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
