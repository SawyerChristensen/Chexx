//
//  MainMenuView.swift
//  Chexx
//
//  Created by Sawyer Christensen on 7/10/24.
//

import SwiftUI

struct MainMenuView: View {
    @AppStorage("backgroundMusicEnabled") private var backgroundMusicEnabled = true
    //@AppStorage("lowMotionEnabled") private var lowMotionEnabled = false
    //@AppStorage("soundEffectsEnabled") private var soundEffectsEnabled = true
    @StateObject private var audioManager = AudioManager()
    @StateObject var authViewModel = AuthViewModel()
    @Environment(\.colorScheme) var colorScheme //detecting the current color scheme
    @State private var isKeyboardVisible = false //for logging in to profile view
    
    @State private var isSettingsPresented = false
    @State private var isProfilePresented = false
    @State private var isTutorialPresented = false
    //the submenus:
    @State private var onlineOptions = false
    @State private var singlePlayerOptions = false
    @State private var passAndPlayOptions = false
    
    //for online play:
    @State private var presentGameLink = false
    @State private var gameLink: String = ""
    @State private var isGameIDEntryPresented = false
    @State private var gameIDToJoin: String = ""
    @State private var navigateToGameView = false
    @State private var showErrorAlert = false
    @State private var errorMessage = "An error occurred."
    
    @State private var hasSavedOnlineGame: Bool = false
    @State private var hasSavedSinglePlayerGame: Bool = false
    @State private var hasSavedPassAndPlayGame: Bool = false
    
    @State private var refreshID = UUID()

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                let screenHeight = geometry.size.height
                let screenWidth = geometry.size.width
                let maxScreenDimension = max(screenHeight, screenWidth)
                
                // MARK: - Main Menu Stack
                ZStack {
                    
                    //BackgroundView() //maybe implement on a later date
                    
                    VStack {
                        
                        if screenWidth > screenHeight { //landscape orientation!
                            
                            Image("king_stencil")
                                .resizable()
                                .scaledToFit()
                                .frame(height: maxScreenDimension * 0.16)
                                .padding(.top, screenHeight * 0.08)
                                .colorInvertIfDarkMode(colorScheme: colorScheme)
                            
                        } else { //portrait orientation!
                            
                            Image("king_stencil")
                                .resizable()
                                .scaledToFit()
                                .frame(height: maxScreenDimension * 0.16)
                                .padding(.top, screenHeight * 0.16)
                                .colorInvertIfDarkMode(colorScheme: colorScheme)
                                //.shadow(color: .white, radius: 5, x: 0, y: 0)
                                //.overlay(colorScheme == .dark ? Color.accentColor .blendMode(.darken) : Color.white .blendMode(.darken)) //try to do nothing if light mode
                        }
                        
                        //WaveText(text: "Hex Chess", fontSize: maxScreenDimension * 0.07)
                        Text("Hex Chess")
                            .font(.system(size: maxScreenDimension * 0.07, weight: .bold, design: .serif))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            .padding(.top, -5)
                        
                        Spacer()
                        
                        if onlineOptions {
                            VStack {
                                // --------------------------------
                                // Create Game Button
                                // --------------------------------
                                Button(action: {
                                    presentGameLink = true
                                    createOnlineGame()
                                }) {
                                    Text("Create Game")
                                        .font(.system(size: maxScreenDimension / 24, weight: .bold, design: .serif))
                                        .frame(width: maxScreenDimension * 0.32, height: maxScreenDimension / 12)
                                        .background(Color.accentColor)
                                        .foregroundColor(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                                        .clipShape(HexagonEdgeRectangleShape())
                                }
                                .padding(8)
                                .sheet(isPresented: $presentGameLink) {
                                    GameLinkSheetView(
                                        isPresented: $presentGameLink,
                                        navigateToGameView: $navigateToGameView,
                                        gameLink: $gameLink,
                                        screenHeight: maxScreenDimension
                                    )
                                    .presentationDetents([.medium])
                                    .presentationDragIndicator(.visible)
                                }

                                // --------------------------------
                                // Join Game Button
                                // --------------------------------
                                Button(action: {
                                    isGameIDEntryPresented = true
                                }) {
                                    Text("Join Game")
                                        .font(.system(size: maxScreenDimension / 24, weight: .bold, design: .serif))
                                        .frame(width: maxScreenDimension * 0.32, height: maxScreenDimension / 12)
                                        .background(Color.accentColor)
                                        .foregroundColor(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                                        .clipShape(HexagonEdgeRectangleShape())
                                }
                                .padding(8)
                                .sheet(isPresented: $isGameIDEntryPresented) {
                                    VStack {
                                        Text("Enter Game ID:")
                                            .font(.title2)
                                        TextField("Game ID", text: Binding(
                                            get: {
                                                self.gameIDToJoin
                                            },
                                            set: { newValue in
                                                self.gameIDToJoin = newValue.uppercased()
                                            }
                                        ))
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .autocorrectionDisabled()
                                            //.textInputAutocapitalization()
                                            .keyboardType(.asciiCapable)
                                            .padding()
                                            .onSubmit {
                                                joinOnlineGame(gameId: gameIDToJoin)
                                            }
                                        Button(action: {
                                            joinOnlineGame(gameId: gameIDToJoin)
                                        }) {
                                            Text("Join Game →")
                                                .font(.system(size: 30, weight: .bold, design: .serif)) //join is HARDCODED, UNLIKE CREATE
                                                .frame(width: 240, height: 60)
                                                .background(Color.accentColor)
                                                .foregroundColor(colorScheme == .dark ? Color(UIColor.systemGray6) : .white)
                                                .clipShape(HexagonEdgeRectangleShape())
                                        }
                                        .padding()
                                    }
                                    .padding()
                                    .presentationDetents([.medium])
                                    .presentationDragIndicator(.visible)
                                }
                                
                                // --------------------------------
                                // Resume Game Button
                                // --------------------------------
                                if hasSavedOnlineGame {
                                    Button(action: {
                                        resumeOnlineGame()
                                    }) {
                                        Text("Resume")
                                            .font(.system(size: maxScreenDimension / 24, weight: .bold, design: .serif))
                                            .frame(width: maxScreenDimension * 0.32, height: maxScreenDimension / 12)
                                            .background(Color.accentColor)
                                            .foregroundColor(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                                            .clipShape(HexagonEdgeRectangleShape())
                                    }
                                    .padding(8)
                                }
                                
                                // NavigationLink to GameView
                                NavigationLink(destination: GameView(isOnlineMultiplayer: true).onAppear {
                                    audioManager.stopBackgroundMusic()
                                }, isActive: $navigateToGameView) {
                                    EmptyView()
                                }
                            }
                            .alert(isPresented: $showErrorAlert) {
                                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                            }
                        }

                        else if singlePlayerOptions { //can also implement variants here
                            VStack {
                                NavigationLink(destination: GameView(isVsCPU: true, startNewGame: true).onAppear {
                                    audioManager.stopBackgroundMusic()
                                }) {
                                    Text("New Game")
                                        .font(.system(size: maxScreenDimension / 24, weight: .bold, design: .serif))
                                        .frame(width: maxScreenDimension * 0.32, height: maxScreenDimension / 12)
                                        .background(Color.accentColor)
                                        .foregroundColor(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                                        .clipShape(HexagonEdgeRectangleShape())
                                }
                                .padding(8)
                                
                                NavigationLink(destination: GameView(isVsCPU: true).onAppear {
                                    audioManager.stopBackgroundMusic()
                                }) {
                                    Text("Resume")
                                        .font(.system(size: maxScreenDimension / 24, weight: .bold, design: .serif))
                                        .frame(width: maxScreenDimension * 0.32, height: maxScreenDimension / 12)
                                        .background(Color.accentColor)
                                        .foregroundColor(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                                        .clipShape(HexagonEdgeRectangleShape())
                                }
                                .padding(8)
                            }
                        }
                            
                        else if passAndPlayOptions {
                            VStack {
                                
                                /*Toggle("Low Motion", isOn: $lowMotionEnabled)
                                    .frame(maxWidth: min(maxScreenDimension / 2.4, 500))
                                    .font(.system(size: min(maxScreenDimension / 36, 28), weight: .semibold, design: .serif))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    .padding(.top, -5)
                                    .padding(.bottom, 20)
                                    .scaleEffect(0.9)*/
                                
                                NavigationLink(destination: GameView(isPassAndPlay: true, startNewGame: true).onAppear {
                                    audioManager.stopBackgroundMusic()
                                }) {
                                    Text("New Game")
                                        .font(.system(size: maxScreenDimension / 24, weight: .bold, design: .serif))
                                        .frame(width: maxScreenDimension * 0.32, height: maxScreenDimension / 12)
                                        .background(Color.accentColor)
                                        .foregroundColor(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                                        .clipShape(HexagonEdgeRectangleShape())
                                }
                                .padding(8)
                                
                                NavigationLink(destination: GameView(isPassAndPlay: true).onAppear {
                                    audioManager.stopBackgroundMusic()
                                }) {
                                    Text("Resume")
                                        .font(.system(size: maxScreenDimension / 24, weight: .bold, design: .serif))
                                        .frame(width: maxScreenDimension * 0.32, height: maxScreenDimension / 12)
                                        .background(Color.accentColor)
                                        .foregroundColor(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                                        .clipShape(HexagonEdgeRectangleShape())
                                }
                                .padding(8)
                            }
                            
                        }
                        
                        else { //no sub menus enabled, go to top level main menu
                            VStack {
                                
                                if hasSavedSinglePlayerGame { //if theres a saved single player game...
                                    Button(action: { // make sure we present the option to resume
                                        singlePlayerOptions = true
                                        //if soundEffectsEnabled { audioManager.playSoundEffect(fileName: "piece_move", fileType: "mp3") }
                                    }) {
                                        Text("Single Player")
                                            .font(.system(size: maxScreenDimension / 24, weight: .bold, design: .serif))
                                            .frame(width: maxScreenDimension * 0.32, height: maxScreenDimension / 12)
                                            .background(Color.accentColor)
                                            .foregroundColor(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                                            .clipShape(HexagonEdgeRectangleShape())
                                    }
                                    .padding(8)
                                    
                                } else { //there is no saved single player game, jump right in!
                                    NavigationLink(destination: GameView(isVsCPU: true).onAppear {
                                        audioManager.stopBackgroundMusic()
                                    }) {
                                        Text("Single Player")
                                            .font(.system(size: maxScreenDimension / 24, weight: .bold, design: .serif))
                                            .frame(width: maxScreenDimension * 0.32, height: maxScreenDimension / 12)
                                            .background(Color.accentColor)
                                            .foregroundColor(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                                            .clipShape(HexagonEdgeRectangleShape())
                                    }
                                    .padding(8)
                                }
                                
                                
                                if hasSavedPassAndPlayGame {
                                    Button(action: {
                                        passAndPlayOptions = true
                                    }) {
                                        Text("Pass & Play")
                                            .font(.system(size: maxScreenDimension / 24, weight: .bold, design: .serif))
                                            .frame(width: maxScreenDimension * 0.32, height: maxScreenDimension / 12)
                                            .background(Color.accentColor)
                                            .foregroundColor(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                                            .clipShape(HexagonEdgeRectangleShape())
                                    }
                                    .padding(8)
                                    
                                } else {
                                    NavigationLink(destination: GameView(isPassAndPlay: true).onAppear {
                                        audioManager.stopBackgroundMusic()
                                    }) {
                                        Text("Pass & Play")
                                            .font(.system(size: maxScreenDimension / 24, weight: .bold, design: .serif))
                                            .frame(width: maxScreenDimension * 0.32, height: maxScreenDimension / 12)
                                            .background(Color.accentColor)
                                            .foregroundColor(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                                            .clipShape(HexagonEdgeRectangleShape())
                                    }
                                    .padding(8)
                                }
                                
                                
                                Button(action: {
                                    onlineOptions = true
                                    //if soundEffectsEnabled { audioManager.playSoundEffect(fileName: "piece_move", fileType: "mp3") }
                                }) {
                                    Text("Online")
                                        .font(.system(size: maxScreenDimension / 24, weight: .bold, design: .serif))
                                        .frame(width: maxScreenDimension * 0.32, height: maxScreenDimension / 12)
                                        .background(Color.accentColor)
                                        .foregroundColor(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                                        .clipShape(HexagonEdgeRectangleShape())
                                }
                                .padding(8)
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
                                        .font(.system(size: maxScreenDimension * 0.05, weight: .bold, design: .serif))
                                }
                            }
                            .padding(.bottom, maxScreenDimension * 0.02)
                            .padding(.top, -maxScreenDimension * 0.02)
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .id(refreshID)  //attach a (rendering?) ID
                .onAppear {
                    refreshID = UUID() // Force a re-init of the view whenever the main menu appears
                
                    DispatchQueue.main.async {
                        checkForSavedOnlineGame()
                        checkForSavedSinglePlayerGame()
                        checkForSavedPassAndPlayGame()
                    }
                }
                
                // MARK: - Top Screen Icons
                HStack(alignment: .top) {
                    
                    // Profile & Leaderboard
                    VStack {
                        // Profile icon
                        Button(action: {
                            isProfilePresented = true
                        }) {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .frame(width: maxScreenDimension / 15, height: maxScreenDimension / 15)
                                .padding(.top, maxScreenDimension / 30)
                                .padding(.leading, maxScreenDimension / 30)
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
                            .background(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
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
                        
                        // Leaderboard Icon
                        Button(action: {
                        //    isLeaderboardPresented = true
                        }) {
                            Image(systemName: "list.bullet.rectangle")
                                .resizable()
                                .frame(width: maxScreenDimension / 15, height: maxScreenDimension / 15)
                                .padding(.top, maxScreenDimension / 30)
                                .padding(.leading, maxScreenDimension / 30)
                        }
                        //.sheet(isPresented: $isLeaderboardPresented) {
                         //   LeaderboardView()
                            // Replace with your actual leaderboard implementation
                        //}
                    }
                    
                    Spacer()
                    
                    // Settings & Tutorial
                    VStack {
                        // Settings icon
                        Button(action: {
                            if let windowScene = UIApplication.shared.connectedScenes
                                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                               let rootViewController = windowScene.windows.first?.rootViewController {
                                let settingsViewController = UIHostingController(rootView: SettingsView(screenHeight: maxScreenDimension))
                                settingsViewController.modalPresentationStyle = .overCurrentContext
                                settingsViewController.view.backgroundColor = .clear // Transparent background
                                rootViewController.present(settingsViewController, animated: true, completion: nil)
                            }
                        }) {
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .frame(width: maxScreenDimension / 15, height: maxScreenDimension / 15)
                                .padding(.top, maxScreenDimension / 30)
                                .padding(.trailing, maxScreenDimension / 30)
                        }
                        
                        // Tutorial Icon
                        Button(action: {
                            isTutorialPresented = true
                        }) {
                            Image(systemName: "book.closed")
                                .resizable()
                                .frame(width: maxScreenDimension / 15, height: maxScreenDimension / 15)
                                .padding(.top, maxScreenDimension / 30)
                                .padding(.trailing, maxScreenDimension / 30)
                        }
                        .sheet(isPresented: $isTutorialPresented) {
                            TutorialView()
                                .presentationDragIndicator(.visible)
                        }
                        
                    }
                }
                
                Spacer() //pushing all icons to the top of the screen
                
            }
            .onAppear { // (of geometry view)
                if backgroundMusicEnabled {
                    audioManager.playBackgroundMusic(fileName: "carmen-habanera", fileType: "mp3")
                }
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
    
    // MARK: - Main Menu Helper functions
    func createOnlineGame() {
        MultiplayerManager.shared.createGame { gameId in
            DispatchQueue.main.async {
                if let gameId = gameId {
                    self.gameLink = gameId
                } else {
                    self.errorMessage = "Failed to create a game."
                    self.showErrorAlert = true
                    self.presentGameLink = false  // Dismiss the sheet
                }
            }
        }
    }

    func joinOnlineGame(gameId: String) {
        MultiplayerManager.shared.joinGame(gameId: gameId) { success in
            if success {
                self.isGameIDEntryPresented = false
                self.navigateToGameView = true
            } else {
                self.errorMessage = "Failed to join the game."
                self.showErrorAlert = true
            }
        }
    }
    
    func checkForSavedOnlineGame() {
        if let savedGameId = UserDefaults.standard.string(forKey: "mostRecentGameId"), !savedGameId.isEmpty {
            hasSavedOnlineGame = true
        } else {
            hasSavedOnlineGame = false
        }
    }
    
    func resumeOnlineGame() {
        MultiplayerManager.shared.resumeGame { success in
            if success {
                self.navigateToGameView = true
            } else {
                self.errorMessage = "No game to resume or an error occurred."
                self.showErrorAlert = true
            }
        }
    }
    
    func checkForSavedSinglePlayerGame() {
        let url = getDocumentsDirectory().appendingPathComponent("currentSinglePlayer")
        hasSavedSinglePlayerGame = FileManager.default.fileExists(atPath: url.path)
    }

    func checkForSavedPassAndPlayGame() {
        let url = getDocumentsDirectory().appendingPathComponent("currentPassAndPlay")
        hasSavedPassAndPlayGame = FileManager.default.fileExists(atPath: url.path)
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
