//
//  MessagesMainMenu.swift
//  Chexx
//
//  Created by Sawyer Christensen on 8/25/25.
//

import SwiftUI
import Messages

struct MessagesMainMenuView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: MenuViewModel
    var onStartGame: () -> Void
    @State private var winCount = 0
    
    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            let screenWidth = geometry.size.width
            
            VStack {
                
                HStack {
                    Image("king_stencil240")
                        .resizable()
                        .scaledToFit()
                        .frame(height: viewModel.presentationStyle == .compact ? screenWidth * 0.1 : screenWidth * 0.15)
                        .colorInvertIfDarkMode(colorScheme: colorScheme)
                        .padding(.trailing, 5)
                    
                    Text("Hex Chess")
                        .font(.system(size: viewModel.presentationStyle == .compact ? screenWidth * 0.07 : screenWidth * 0.1, weight: .semibold, design: .serif))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .padding(.bottom, 5)

                ZStack {
                    
                    Image("StartingPositions")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: viewModel.presentationStyle == .compact ? 420 : 600,
                            height: viewModel.presentationStyle == .compact ? 420 : 600)
                        .position(
                            x: viewModel.presentationStyle == .compact ? screenWidth * 0.33 : screenWidth * 0.5,
                            y: viewModel.presentationStyle == .compact ? screenHeight * 0.9 : screenHeight * 0.8)
                        .rotationEffect(.degrees(viewModel.presentationStyle == .compact ? 15 : 0))
                    
                    Button(action: {
                        onStartGame()
                    }) {
                        WaveText(text: "Start Game!", fontSize: viewModel.presentationStyle == .compact ? screenWidth * 0.07 : screenWidth * 0.11)
                            //.font(.system(size: screenWidth * 0.1, weight: .semibold, design: .serif))
                            .padding()
                            .frame(
                                minWidth: viewModel.presentationStyle == .compact ? screenWidth * 0.33 : screenWidth * 0.45,
                                maxHeight: viewModel.presentationStyle == .compact ? screenWidth * 0.1 : screenWidth * 0.15)
                            .background(Color("AccentColor"))
                            .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                            .clipShape(HexagonEdgeRectangleShape())
                            .position(
                                x: viewModel.presentationStyle == .compact ? screenWidth * 0.7 : screenWidth * 0.5,
                                y: viewModel.presentationStyle == .compact ? screenHeight * 0.1 : screenHeight * 0.15)
                    }
                    
                    Text("Total Wins: \(winCount)")
                        .font(.system(size: viewModel.presentationStyle == .compact ? screenWidth * 0.05 : screenWidth * 0.07, weight: .regular, design: .serif))
                        .foregroundColor(colorScheme == .dark ? Color(white: 0.8) : Color(white: 0.3))
                        .position(
                            x: viewModel.presentationStyle == .compact ? screenWidth * 0.7 : screenWidth * 0.5,
                            y: viewModel.presentationStyle == .compact ? screenHeight * 0.25 : screenHeight * 0.25
                        )
                    
                }
            }
            .onAppear {
                self.winCount = WinTracker.shared.getWinCount()}
        }
        .background(colorScheme == .dark ? Color(UIColor(hex: "#262626")) : Color.white)
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

//so we can smoothly transition between the compact and expanded menu
class MenuViewModel: ObservableObject {
    @Published var presentationStyle: MSMessagesAppPresentationStyle

    init(presentationStyle: MSMessagesAppPresentationStyle) {
        self.presentationStyle = presentationStyle
    }
}

class WinTracker {
    static let shared = WinTracker()
    private let winsKey = "totalWins"

    func getWinCount() -> Int {
        return UserDefaults.standard.integer(forKey: winsKey)
    }
    
    func incrementWins() {
        var currentWins = getWinCount()
        currentWins += 1
        UserDefaults.standard.set(currentWins, forKey: winsKey)
    }
    
    func resetWins() {
        UserDefaults.standard.removeObject(forKey: winsKey)
    }
}
