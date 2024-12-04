//
//  GameView.swift
//  Chexx
//
//  Created by Sawyer Christensen on 8/8/24.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    @State private var redStatusText: String = ""
    @State private var whiteStatusText: String = ""
    @State var isVsCPU: Bool = false
    @State var isPassAndPlay: Bool = false
    @State var isOnlineMultiplayer: Bool = false
    @State private var scene: SKScene?
    var startNewGame: Bool = false
    //@State var variant: String

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(UIColor(hex: "#262626")).edgesIgnoringSafeArea(.all)
                
                if let scene = scene {
                    SpriteView(scene: scene)
                        .ignoresSafeArea()
                }
                
                if geometry.size.height > geometry.size.width {
                    // Text view to display status messages
                    Text(redStatusText)
                        .font(.system(size: geometry.size.height / 20, weight: .bold, design: .serif))
                        .foregroundColor(.red)
                        .shadow(color: .red, radius: 5, x: 0, y: 0)
                        .padding(.bottom, geometry.size.height * 0.95)
                    
                    Text(whiteStatusText)
                        .font(.system(size: geometry.size.height / 20, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .shadow(color: .white, radius: 5, x: 0, y: 0)
                        .padding(.bottom, geometry.size.height * 0.95)
                }
            }
            .onAppear {
                if scene == nil {
                    if isVsCPU && startNewGame == true {
                        deleteGameFile(filename: "currentSinglePlayer")
                    }
                    if isPassAndPlay && startNewGame == true {
                        deleteGameFile(filename: "currentPassAndPlay")
                    }
                    scene = createScene(size: geometry.size) 
                }
            }
            .onChange(of: geometry.size) { _, newSize in
                scene?.size = newSize
                if geometry.size.height > geometry.size.width {
                    scene?.scaleMode = .aspectFill
                } else {
                    scene?.scaleMode = .resizeFill
                }
            }
        }
    }

    private func createScene(size: CGSize) -> SKScene {
        let scene = GameScene(size: size, isVsCPU: isVsCPU, isPassAndPlay: isPassAndPlay, isOnlineMultiplayer: isOnlineMultiplayer)
        scene.scaleMode = .aspectFill
        scene.isVsCPU = isVsCPU
        //scene.variant = variant
        scene.isPassAndPlay = isPassAndPlay
        scene.isOnlineMultiplayer = isOnlineMultiplayer
        scene.redStatusTextUpdater = { text in
            self.redStatusText = text // Update the red status text from the GameScene
        }
        scene.whiteStatusTextUpdater = { text in
            self.whiteStatusText = text // Update the white status text from the GameScene
        }
        return scene
    }

}
