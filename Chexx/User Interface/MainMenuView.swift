//
//  MainMenuView.swift
//  Chexx
//
//  Created by Sawyer Christensen on 7/10/24.
//

import SwiftUI
import AVFoundation //for audio

struct MainMenuView: View {
    @State private var audioPlayer: AVAudioPlayer?//declaring an avaudioplayer instance
    @State private var singlePlayerOptions = false
    @Environment(\.colorScheme) var colorScheme //detecting the current color scheme

    var body: some View {
            NavigationView {
                ZStack {
                    //BackgroundView()

                    VStack {
                        //Spacer()

                        Image("white_king")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .padding(.top, 100)
                            .colorInvertIfDarkMode(colorScheme: colorScheme)

                        Text("Hex Chess")
                            .font(.system(size: 50, weight: .bold, design: .serif))
                            .padding(.top, -5)

                        Spacer()

                        if singlePlayerOptions {
                            Button(action: {
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                       let window = windowScene.windows.first {
                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                        if let gameViewController = storyboard.instantiateViewController(withIdentifier: "GameViewController") as? GameViewController {
                                            ///gameViewController.isTabletopMode = true
                                            window.rootViewController = gameViewController
                                            window.makeKeyAndVisible()
                                        }
                                    }
                            }) {
                                Text("Tabletop")
                                    .font(.system(size: 33, weight: .bold, design: .serif))
                                    .frame(width: 233, height: 60)
                                    .background(Color.accentColor)
                                    .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                                    .clipShape(HexagonEdgeRectangleShape())
                            }.padding(5)

                            Button(action: {
                                // *INPUT Action for VS CPU*
                            }) {
                                Text("vs CPU")
                                    .font(.system(size: 33, weight: .bold, design: .serif))
                                    .frame(width: 233, height: 60)
                                    .background(Color.accentColor)
                                    .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                                    .clipShape(HexagonEdgeRectangleShape())
                            }.padding(5)
                            
                        } else {
                            // Display the original buttons
                            Button(action: {
                                // Navigate to the game view controller
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let window = windowScene.windows.first {
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    if let gameViewController = storyboard.instantiateViewController(withIdentifier: "GameViewController") as? GameViewController {
                                        window.rootViewController = gameViewController
                                        window.makeKeyAndVisible()
                                    }
                                }
                            }) {
                                Text("Tutorial")
                                    .font(.system(size: 33, weight: .bold, design: .serif))
                                    //.padding()
                                    .frame(width: 233, height: 60)
                                    .background(Color.accentColor)
                                    .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                                    .clipShape(HexagonEdgeRectangleShape())
                                    //.overlay(HexagonEdgeRectangleShape().stroke(Color.white, lineWidth: 2))
                            }.padding(5)

                            Button(action: {
                                withAnimation {
                                    singlePlayerOptions = true
                                }
                            }) {
                                Text("New Game")
                                    .font(.system(size: 33, weight: .bold, design: .serif))
                                    //.padding()
                                    .frame(width: 233, height: 60)
                                    .background(Color.accentColor)
                                    .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                                    .clipShape(HexagonEdgeRectangleShape())
                                    //.overlay(HexagonEdgeRectangleShape().stroke(Color.white, lineWidth: 2))
                            }.padding(5)

                            Button(action: {
                                // Navigate to the multiplayer game view controller
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let window = windowScene.windows.first {
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    if let gameViewController = storyboard.instantiateViewController(withIdentifier: "GameViewController") as? GameViewController {
                                        window.rootViewController = gameViewController
                                        window.makeKeyAndVisible()
                                    }
                                }
                            }) {
                                Text("Multiplayer")
                                    .font(.system(size: 33, weight: .bold, design: .serif))
                                    //.padding()
                                    .frame(width: 233, height: 60)
                                    .background(Color.accentColor)
                                    .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                                    .clipShape(HexagonEdgeRectangleShape())
                                    //.overlay(HexagonEdgeRectangleShape().stroke(Color.white, lineWidth: 2))
                            }.padding(5)
                        }

                        Spacer()
                        Spacer()
                    }
                    VStack {
                        Spacer()
                        if singlePlayerOptions {
                            Button(action: {
                                // Go back to the original buttons
                                withAnimation {
                                    singlePlayerOptions = false
                                }
                            }) {
                                HStack {
                                    Image(systemName: "arrow.backward")
                                    //Text("Back")
                                }
                                .font(.system(size: 33, weight: .bold, design: .serif))
                                .frame(width: 233, height: 60)
                            }
                            .padding(.bottom, 100) // Adjust the bottom padding as needed
                        }
                    }
                }
            .navigationBarItems(
                leading: HStack {
                    Spacer()
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .padding(.top, 20)
                            .padding(10)
                    }
                },
                trailing: HStack {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .padding(.top, 20)
                            .padding(10)
                    }
                    Spacer()
                }
            )
        }
        //.onAppear {
        //    playBackgroundMusic()
        //}
        .onDisappear {
            stopBackgroundMusic()
        }
    }
    
    // Function to play background music
    func playBackgroundMusic() {
        guard let path = Bundle.main.path(forResource: "carmen-habanera", ofType: "mp3") else {
            return
        }

        let url = URL(fileURLWithPath: path)

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.volume = 0.3
            audioPlayer?.play()
        } catch {
            print("Could not load file")
        }
    }

    // Function to stop background music
    func stopBackgroundMusic() {
        audioPlayer?.stop()
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
