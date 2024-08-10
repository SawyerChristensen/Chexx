//
//  MainMenuView.swift
//  Chexx
//
//  Created by Sawyer Christensen on 7/10/24.
//

import SwiftUI

struct MainMenuView: View {
    @StateObject private var audioManager = AudioManager()
    @Environment(\.colorScheme) var colorScheme //detecting the current color scheme
    @State private var isSettingsPresented = false
    @State private var isProfilePresented = false
    @State private var singlePlayerOptions = false

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                let screenHeight = geometry.size.height
                
                ZStack {
                    //BackgroundView()
                    VStack {
                        
                        Image("white_king")
                            .resizable()
                            .scaledToFit()
                            .frame(height: screenHeight * 0.14)
                            .padding(.top, screenHeight * 0.14)
                            .colorInvertIfDarkMode(colorScheme: colorScheme)
                        
                        Text("Hex Chess")
                            .font(.system(size: screenHeight * 0.07, weight: .bold, design: .serif))
                            .padding(.top, -5)
                        
                        Spacer()
                        
                        if singlePlayerOptions {
                            VStack {
                                NavigationLink(destination: GameView(isTabletopMode: true).onAppear { audioManager.stop() }) {
                                    Text("Tabletop")
                                        .font(.system(size: screenHeight * 0.046, weight: .bold, design: .serif))
                                        .frame(width: screenHeight * 0.32, height: screenHeight / 12)
                                        .background(Color.accentColor)
                                        .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                                        .clipShape(HexagonEdgeRectangleShape())
                                }
                                .padding(5)
                                
                                NavigationLink(destination: GameView(isVsCPU: true).onAppear { audioManager.stop() }) {
                                    Text("vs CPU")
                                        .font(.system(size: screenHeight * 0.046, weight: .bold, design: .serif))
                                        .frame(width: screenHeight * 0.32, height: screenHeight / 12)
                                        .background(Color.accentColor)
                                        .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                                        .clipShape(HexagonEdgeRectangleShape())
                                }
                                .padding(5)
                            }
                        } else {
                            VStack {
                                NavigationLink(destination: GameView().onAppear { audioManager.stop() }) {
                                    Text("Tutorial")
                                        .font(.system(size: screenHeight * 0.046, weight: .bold, design: .serif))
                                        .frame(width: screenHeight * 0.32, height: screenHeight / 12)
                                        .background(Color.accentColor)
                                        .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                                        .clipShape(HexagonEdgeRectangleShape())
                                }
                                .padding(5)
                                
                                Button(action: {
                                    singlePlayerOptions = true
                                }) {
                                    Text("New Game")
                                        .font(.system(size: screenHeight * 0.046, weight: .bold, design: .serif))
                                        .frame(width: screenHeight * 0.32, height: screenHeight / 12)
                                        .background(Color.accentColor)
                                        .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                                        .clipShape(HexagonEdgeRectangleShape())
                                }
                                .padding(5)
                                
                                NavigationLink(destination: GameView().onAppear { audioManager.stop() }) {
                                    Text("Multiplayer")
                                        .font(.system(size: screenHeight * 0.046, weight: .bold, design: .serif))
                                        .frame(width: screenHeight * 0.32, height: screenHeight / 12)
                                        .background(Color.accentColor)
                                        .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                                        .clipShape(HexagonEdgeRectangleShape())
                                }
                                .padding(5)
                            }
                        }
                        
                        Spacer()
                        
                        if singlePlayerOptions {
                            Button(action: {
                                withAnimation {
                                    singlePlayerOptions = false
                                }
                            }) {
                                HStack {
                                    Image(systemName: "arrow.backward")
                                        .font(.system(size: screenHeight * 0.046, weight: .bold, design: .serif))
                                }
                            }
                            .padding(.bottom, screenHeight * 0.14)
                        }
                    }
                    // Center everything horizontally
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                
                // Overlay for Profile and Settings Icons
                HStack {
                    // Profile icon on the left
                    Button(action: {
                        isProfilePresented = true
                    }) {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: screenHeight / 18, height: screenHeight / 18)
                            .padding(10)
                    }
                    .fullScreenCover(isPresented: $isProfilePresented) {
                        ProfileView()
                            .background(Color.white.opacity(0.001).edgesIgnoringSafeArea(.all))
                            .onTapGesture {
                                isProfilePresented = false
                            }
                    }
                    Spacer() // Push the settings icon to the right
                }
                HStack {
                    Spacer()
                    // Settings icon on the right
                    Button(action: {
                        isSettingsPresented = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .resizable()
                            .frame(width: screenHeight / 18, height: screenHeight / 18)
                            .padding(10)
                    }
                    .fullScreenCover(isPresented: $isSettingsPresented) {
                        ZStack {
                                // Transparent background that dismisses the view when tapped
                                Color.white.opacity(0.001)
                                    .edgesIgnoringSafeArea(.all)
                                    .onTapGesture {
                                        isSettingsPresented = false
                                    }
                                
                                SettingsView(screenHeight: screenHeight)
                            }
                            .background(Color.clear) // Make sure background is clear
                            .edgesIgnoringSafeArea(.all)
                        }
                }
                Spacer()
            }
            //.onAppear {
            //    audioManager.play()
            //}
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Ensure the NavigationView behaves well on iPad
    }
}

struct SettingsModalView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("highlightEnabled") private var highlightEnabled = true

    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.headline)
                .padding()

            Toggle("Enable Highlight", isOn: $highlightEnabled)
                .padding()

            Button(action: {
                // Handle other settings actions
            }) {
                Text("Other Settings")
            }

            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 10)
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


struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}
