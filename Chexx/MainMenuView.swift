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
    @Environment(\.colorScheme) var colorScheme //detecting the current color scheme

    var body: some View {
        ZStack {
            // Change background based on color scheme
            if colorScheme == .dark {
                darkModeBackground()
            } else {
                lightModeBackground()
            }

            VStack {
                Spacer()
                
                Image("white_king")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    //.padding(.top, 50)
                    .colorInvertIfDarkMode(colorScheme: colorScheme)
                
                Text("Hex Chess")
                    .font(.system(size: 50, weight: .bold, design: .serif))
                    .padding(.top, 5)
                
                Spacer()

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
                    Text("New Game")
                        .font(.system(size: 30, weight: .bold, design: .serif))
                        .padding()
                        .frame(width: 200, height: 60)
                        .background(Color.accentColor)
                        .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                        .clipShape(HexagonEdgeRectangleShape()) // Apply the custom hexagonal edge shape here
                        //.overlay(HexagonEdgeRectangleShape().stroke(Color.white, lineWidth: 2)) // Optional: Add a border
                }

                Spacer()
                Spacer()
            }
            .onAppear {
                playBackgroundMusic()
            }
            .onDisappear {
                stopBackgroundMusic()
            }
        }
        //.edgesIgnoringSafeArea(.all)
    }
    
    // Background for light mode
    func lightModeBackground() -> some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
/*
            LinearGradient(
                gradient: Gradient(colors: [Color.gray.opacity(0.2), Color.white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
*/
            Image("marble_white")
                .resizable()
                .scaledToFill()
                .opacity(0.5)
                .edgesIgnoringSafeArea(.all)
        }
    }

    // Background for dark mode
    func darkModeBackground() -> some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
/*
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.gray]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
*/
            Image("marble_black")
                .resizable()
                .scaledToFill()
                .opacity(0.5)
                .edgesIgnoringSafeArea(.all)
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
