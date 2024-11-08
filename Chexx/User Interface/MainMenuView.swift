//
//  MainMenuView.swift
//  Chexx
//
//  Created by Sawyer Christensen on 7/10/24.
//

import SwiftUI

struct MainMenuView: View {
    @AppStorage("backgroundMusicEnabled") private var backgroundMusicEnabled = true
    @StateObject private var audioManager = AudioManager()
    @StateObject var authViewModel = AuthViewModel()
    @Environment(\.colorScheme) var colorScheme //detecting the current color scheme
    @State private var isKeyboardVisible = false
    @State private var isSettingsPresented = false
    @State private var isProfilePresented = false
    @State private var onlineOptions = false
    @State private var singlePlayerOptions = false
    @State private var passAndPlayOptions = false

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                let screenHeight = geometry.size.height
                let screenWidth = geometry.size.width
                
                ZStack {
                    //BackgroundView()
                    VStack {
                        
                        Image("white_king")
                            .resizable()
                            .scaledToFit()
                            .frame(height: screenHeight * 0.15)
                            .padding(.top, screenHeight * 0.15)
                            .colorInvertIfDarkMode(colorScheme: colorScheme)
                            //.shadow(color: .white, radius: 5, x: 0, y: 0)
                            //.overlay(colorScheme == .dark ? Color.accentColor .blendMode(.darken) : Color.white .blendMode(.darken)) //try to do nothing if light mode
                        
                        //WaveText(text: "Hex Chess", fontSize: screenHeight * 0.07)
                        Text("Hex Chess")
                            .font(.system(size: screenHeight * 0.07, weight: .bold, design: .serif))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            .padding(.top, -5)
                        
                        Spacer()
                        
                        if onlineOptions {
                            VStack {
                                NavigationLink(destination: GameView().onAppear { audioManager.stopBackgroundMusic() }) {
                                    Text("Random")
                                        .font(.system(size: screenHeight / 24, weight: .bold, design: .serif))
                                        .frame(width: screenHeight * 0.32, height: screenHeight / 12)
                                        .background(Color.accentColor)
                                        .foregroundColor(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                                        .clipShape(HexagonEdgeRectangleShape())
                                }
                                .padding(5)
                                
                                NavigationLink(destination: GameView().onAppear { audioManager.stopBackgroundMusic() }) {
                                    Text("vs Friend")
                                        .font(.system(size: screenHeight / 24, weight: .bold, design: .serif))
                                        .frame(width: screenHeight * 0.32, height: screenHeight / 12)
                                        .background(Color.accentColor)
                                        .foregroundColor(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                                        .clipShape(HexagonEdgeRectangleShape())
                                }
                                .padding(5)
                            }
                        }
                        
                        else if singlePlayerOptions { //can also implement variants here
                            VStack {
                                NavigationLink(destination: GameView(isVsCPU: true, startNewGame: true).onAppear {
                                    audioManager.stopBackgroundMusic()
                                }) {
                                    Text("New Game")
                                        .font(.system(size: screenHeight / 24, weight: .bold, design: .serif))
                                        .frame(width: screenHeight * 0.32, height: screenHeight / 12)
                                        .background(Color.accentColor)
                                        .foregroundColor(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                                        .clipShape(HexagonEdgeRectangleShape())
                                }
                                .padding(5)
                                
                                NavigationLink(destination: GameView(isVsCPU: true).onAppear {
                                    audioManager.stopBackgroundMusic()
                                }) {
                                    Text("Resume")
                                        .font(.system(size: screenHeight / 24, weight: .bold, design: .serif))
                                        .frame(width: screenHeight * 0.32, height: screenHeight / 12)
                                        .background(Color.accentColor)
                                        .foregroundColor(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                                        .clipShape(HexagonEdgeRectangleShape())
                                }
                                .padding(5)
                            }
                        }
                            
                        else if passAndPlayOptions {
                            VStack {
                                
                                //possiby have a toggle here for low motion mode (either here or settings)
                                
                                NavigationLink(destination: GameView(isPassAndPlay: true, startNewGame: true).onAppear {
                                    audioManager.stopBackgroundMusic()
                                }) {
                                    Text("New Game")
                                        .font(.system(size: screenHeight / 24, weight: .bold, design: .serif))
                                        .frame(width: screenHeight * 0.32, height: screenHeight / 12)
                                        .background(Color.accentColor)
                                        .foregroundColor(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                                        .clipShape(HexagonEdgeRectangleShape())
                                }
                                .padding(5)
                                
                                NavigationLink(destination: GameView(isPassAndPlay: true).onAppear {
                                    audioManager.stopBackgroundMusic()
                                }) {
                                    Text("Resume")
                                        .font(.system(size: screenHeight / 24, weight: .bold, design: .serif))
                                        .frame(width: screenHeight * 0.32, height: screenHeight / 12)
                                        .background(Color.accentColor)
                                        .foregroundColor(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                                        .clipShape(HexagonEdgeRectangleShape())
                                }
                                .padding(5)
                            }
                            
                        } else {
                            VStack {
                                NavigationLink(destination: GameView().onAppear { audioManager.stopBackgroundMusic() }) {
                                    Text("Tutorial")
                                        .font(.system(size: screenHeight / 24, weight: .bold, design: .serif))
                                        .frame(width: screenHeight * 0.32, height: screenHeight / 12)
                                        .background(Color.accentColor)
                                        .foregroundColor(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                                        .clipShape(HexagonEdgeRectangleShape())
                                }
                                .padding(5)
                                
                                Button(action: {
                                    singlePlayerOptions = true
                                }) {
                                //NavigationLink(destination: GameView(isVsCPU: true).onAppear { audioManager.stopBackgroundMusic() }) {
                                    Text("Single Player")
                                        .font(.system(size: screenHeight / 24, weight: .bold, design: .serif))
                                        .frame(width: screenHeight * 0.32, height: screenHeight / 12)
                                        .background(Color.accentColor)
                                        .foregroundColor(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                                        .clipShape(HexagonEdgeRectangleShape())
                                }
                                .padding(5)
                                
                                Button(action: {
                                    passAndPlayOptions = true
                                }) {
                                //NavigationLink(destination: GameView(isPassAndPlay: true).onAppear { audioManager.stopBackgroundMusic() }) {
                                    Text("Pass & Play")
                                        .font(.system(size: screenHeight / 24, weight: .bold, design: .serif))
                                        .frame(width: screenHeight * 0.32, height: screenHeight / 12)
                                        .background(Color.accentColor)
                                        .foregroundColor(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                                        .clipShape(HexagonEdgeRectangleShape())
                                }
                                .padding(5)
                                
                                Button(action: {
                                    onlineOptions = true
                                }) {
                                    Text("Online")
                                        .font(.system(size: screenHeight / 24, weight: .bold, design: .serif))
                                        .frame(width: screenHeight * 0.32, height: screenHeight / 12)
                                        .background(Color.accentColor)
                                        .foregroundColor(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                                        .clipShape(HexagonEdgeRectangleShape())
                                }
                                .padding(5)
                                .padding(.bottom)
                            }
                            
                        }
                        
                        Spacer()
                        
                        if onlineOptions || singlePlayerOptions || passAndPlayOptions {
                            Button(action: {
                                withAnimation {
                                    onlineOptions = false
                                    singlePlayerOptions = false
                                    passAndPlayOptions = false
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
                            .frame(width: screenHeight / 16, height: screenHeight / 16)
                            .padding(screenHeight / 30)
                    }
                    .fullScreenCover(isPresented: $isProfilePresented) {
                        VStack {
                            
                            Spacer()
                            
                            ProfileView(screenHeight: screenHeight, screenWidth: screenWidth)
                                .environmentObject(authViewModel)
                            
                            Spacer()
                            
                            if !isKeyboardVisible { //is keyboard is visible, hide the close button
                                // Dismiss button at the bottom
                                Button(action: {
                                    isProfilePresented = false
                                }) {
                                    Text("Close")
                                        .font(.system(size: screenHeight / 30, weight: .bold, design: .serif))
                                        .padding()
                                        .frame(width: screenHeight / 4.5, height: screenHeight / 18)
                                        .background(Color.accentColor)
                                        .foregroundColor(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                                        .clipShape(HexagonEdgeRectangleShape())
                                }
                            }
                        }
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .onAppear {
                            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
                                isKeyboardVisible = true
                            }
                            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                                isKeyboardVisible = false
                            }
                        }
                        .onDisappear {
                            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
                            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
                        }
                    }
                    Spacer() // Push the settings icon to the right
                }
                HStack {
                    Spacer()
                    // Settings icon on the right
                    Button(action: {
                        if let windowScene = UIApplication.shared.connectedScenes
                                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                               let rootViewController = windowScene.windows.first?.rootViewController {
                            let settingsViewController = UIHostingController(rootView: SettingsViewController(screenHeight: screenHeight))
                            settingsViewController.modalPresentationStyle = .overCurrentContext
                            settingsViewController.view.backgroundColor = .clear // Transparent background
                            rootViewController.present(settingsViewController, animated: true, completion: nil)
                        }
                    }) {
                        Image(systemName: "gearshape.fill")
                            .resizable()
                            .frame(width: screenHeight / 16, height: screenHeight / 16)
                            .padding(screenHeight / 30)
                    }
                }
                Spacer()
            }
            .onAppear {
                if backgroundMusicEnabled {
                    audioManager.playBackgroundMusic(fileName: "carmen-habanera", fileType: "mp3")
                } //need to stop music immediatey if this is disabled
            }
            .onChange(of: backgroundMusicEnabled) {
                if backgroundMusicEnabled {
                    audioManager.playBackgroundMusic(fileName: "carmen-habanera", fileType: "mp3")
                } else {
                    audioManager.stopBackgroundMusic()
                }
            }
            .background(Color(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)) //change this to change main menu background color
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Ensure the NavigationView behaves well on iPad
    }
}
/*
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
}*/

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
