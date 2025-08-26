//
//  MessagesMainMenu.swift
//  Chexx
//
//  Created by Sawyer Christensen on 8/25/25.
//

import SwiftUI

struct MessagesMainMenuView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var onStartGame: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            let screenWidth = geometry.size.width
            
            VStack {
                
                HStack {
                    Image("king_stencil240")
                        .resizable()
                        .scaledToFit()
                        .frame(height: screenWidth * 0.1)
                        .colorInvertIfDarkMode(colorScheme: colorScheme)
                        .padding(.trailing, 5)
                    
                    Text("Hex Chess")
                        .font(.system(size: screenWidth * 0.07, weight: .semibold, design: .serif))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                }
                .padding(.bottom, 5)
                .frame(maxWidth: .infinity)
                .background(Color(.white))
                
                Divider()

                ZStack {
                    
                    Image("StartingPositions")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 420, height: 420)
                        .position(x: screenWidth * 0.37, y: screenHeight * 0.9)
                        .rotationEffect(.degrees(15))
                    
                    Button(action: {
                        onStartGame()
                    }) {
                        WaveText(text: "Start Game!", fontSize: screenWidth * 0.08)
                            //.font(.system(size: screenWidth * 0.1, weight: .semibold, design: .serif))
                            .padding()
                            .frame(minWidth: screenWidth * 0.33, maxHeight: screenWidth * 0.1)
                            .background(Color("HexChessAccentColor"))
                            .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                            .clipShape(HexagonEdgeRectangleShape())
                            //.overlay(
                            //    HexagonEdgeRectangleShape()
                            //        .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 1)
                            //)
                            .position(x: screenWidth * 0.7, y: screenHeight * 0.13)
                    }
                }
                //.padding(.top, 5)
            }
        }
        //.background(Color(.systemGray6))
    }
}

struct HexagonEdgeRectangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let width = rect.size.width
        let height = rect.size.height
        let hexagonHeight = height / 2

        var path = Path()
        
        path.move(to: CGPoint(x: 0, y: hexagonHeight))
        path.addLine(to: CGPoint(x: hexagonHeight / 2, y: 0))
        path.addLine(to: CGPoint(x: width - hexagonHeight / 2, y: 0))
        path.addLine(to: CGPoint(x: width, y: hexagonHeight))
        path.addLine(to: CGPoint(x: width - hexagonHeight / 2, y: height))
        path.addLine(to: CGPoint(x: hexagonHeight / 2, y: height))
        path.closeSubpath()

        return path
    }
}

extension View {
    func colorInvertIfDarkMode(colorScheme: ColorScheme) -> some View {
        self.modifier(ColorInvertIfDarkModeModifier(colorScheme: colorScheme))
    }
}

struct ColorInvertIfDarkModeModifier: ViewModifier {
    let colorScheme: ColorScheme

    func body(content: Content) -> some View {
        if colorScheme == .dark {
            return AnyView(content.colorInvert())
        } else {
            return AnyView(content)
        }
    }
}

struct WaveText: View {
    let text: String
    let fontSize: CGFloat
    @State private var waveOffset: CGFloat = 0
    @State private var startWave: Bool = false
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<text.count, id: \.self) { index in
                Text(String(Array(text)[index]))
                    //.fixedSize()
                    .font(.system(size: fontSize - CGFloat((text.count)) * 0.5, weight: .bold, design: .serif))
                    .offset(y: startWave ? waveOffset(for: index) : 0) // so the text starts out flat
            }
        }
        .onReceive(timer) { _ in
            withAnimation(Animation.linear(duration: 4)) { // wave speed
                if startWave {
                   waveOffset += 1
                } else {
                    startWave = true //starts the wave after 0.1 seconds on flat text
                }
            }
        }
    }
    
    private func waveOffset(for index: Int) -> CGFloat {
        return sin((Double(index) + Double(waveOffset)) * .pi / 5) * 30 // wave amplitude
    }
}
