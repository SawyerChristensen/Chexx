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
    @State private var whiteStatusTextMini: String = ""
    @State var isVsCPU: Bool = false
    @State var isPassAndPlay: Bool = false
    @State var isOnlineMultiplayer: Bool = false
    @State private var scene: SKScene?
    var startNewGame: Bool = false
    //@State var variant: String

    var body: some View {
        GeometryReader { geometry in

            ZStack { //background color
                Color(UIColor(hex: "#262626")).edgesIgnoringSafeArea(.all)
                
                if let scene = scene { //the actual board
                    SpriteView(scene: scene)
                        .ignoresSafeArea()
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
            
            //game text in portrait mode
            if geometry.size.height > geometry.size.width {
                
                if !isOnlineMultiplayer {
                    ZStack {
                        if !redStatusText.isEmpty {
                            Text(redStatusText)
                                .font(.system(size: geometry.size.height / 20, weight: .bold, design: .serif))
                                .foregroundColor(.red)
                                .shadow(color: .red, radius: 5, x: 0, y: 0)
                        } else {
                            Text(whiteStatusText)
                                .font(.system(size: geometry.size.height / 20, weight: .bold, design: .serif))
                                .foregroundColor(.white)
                                .shadow(color: .white, radius: 5, x: 0, y: 0)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .padding(.bottom, geometry.size.height * 0.95)
                    
                } else {
                    VStack(spacing: 10) {
                        
                        //opponent info
                        if MultiplayerManager.shared.opponentName != "" {
                            HStack(spacing: 10) {
                                Text("Opponent:")
                                    .font(.system(size: geometry.size.height / 32, design: .serif))
                                    .foregroundColor(.white)
                                //.padding()
                                
                                // Opponent's Profile Image
                                if let url = MultiplayerManager.shared.opponentProfileImageURL {
                                    AsyncImage(url: url) { image in
                                        image.resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                    } placeholder: {
                                        Circle()
                                            .fill(Color.gray)
                                            .frame(width: 40, height: 40)
                                    }
                                }
                                
                                // Opponent's Name
                                Text(MultiplayerManager.shared.opponentName)
                                    .font(.system(size: geometry.size.height / 32, weight: .bold, design: .serif))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        if !redStatusText.isEmpty {
                            Text(redStatusText)
                                .font(.system(size: geometry.size.height / 28, weight: .bold, design: .serif))
                                .foregroundColor(.red)
                                .shadow(color: .red, radius: 5, x: 0, y: 0)
                        } else {
                            //whose turn is it, anyway?
                            Text(whiteStatusTextMini)
                                .font(.system(size: geometry.size.height / 36, design: .serif))
                                .foregroundColor(.white)
                                //.shadow(color: .white, radius: 5, x: 0, y: 0)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .padding(.bottom, geometry.size.height)
                }
            }
        }
    }

    private func createScene(size: CGSize) -> SKScene {
        let newScene = GameScene(size: size, isVsCPU: isVsCPU, isPassAndPlay: isPassAndPlay, isOnlineMultiplayer: isOnlineMultiplayer)
        newScene.scaleMode = .aspectFill
        //scene.variant = variant
        newScene.redStatusTextUpdater = { text in
            self.redStatusText = text // Update the red status text from the GameScene
        }
        newScene.whiteStatusTextUpdater = { text in
            self.whiteStatusText = text // Update the white status text from the GameScene
        }
        newScene.whiteStatusTextMiniUpdater = { text in
            self.whiteStatusTextMini = text // Update the mini white status text from the GameScene
        }
        
        return newScene
    }
}
