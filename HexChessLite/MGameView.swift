//
//  MessageGameView.swift
//  Chexx
//
//  Created by Sawyer Christensen on 8/31/25.
//

import SwiftUI
import SpriteKit

struct MessagesGameView: View {
    @State var scene: SKScene?
    weak var delegate: GameSceneDelegate?
    
    @State private var redStatusText: String = ""
    @State private var isLocalPlayersTurn = true
    @State private var waitingForOpponentText: String = NSLocalizedString("Waiting for opponent", comment: "Waiting text in iMessage")
    @State private var waitingForOpponentBackgroundOpacity: Double = 0.8
    @State private var waitingTimer: Timer?

    var body: some View {
        GeometryReader { geometry in

            ZStack { //background color
                Color(UIColor(hex: "#262626")).edgesIgnoringSafeArea(.all)
                
                if let scene = scene { //the actual board
                    SpriteView(scene: scene)
                        //.ignoresSafeArea()
                }
                
                Text(redStatusText)
                    .font(.system(size: geometry.size.height / 20, weight: .bold, design: .serif))
                    .foregroundColor(.red)
                    .shadow(color: .red, radius: 5, x: 0, y: 0)
                    .padding(.bottom, geometry.size.height * 0.8) //5% away from the top
                
                if !isLocalPlayersTurn && !isGameOver {
                    //Color.black.opacity(0.2) //should block all touches to the scene...
                        //.ignoresSafeArea()
                        //.transition(.opacity)
                    
                    Text(waitingForOpponentText)
                        .font(.system(size: geometry.size.width / 20, weight: .semibold, design: .serif))
                        .foregroundColor(.white)
                        .padding()
                    
                        .frame(width: geometry.size.width * 0.7)
                        .background(
                            Color(white: 0.2)
                                .cornerRadius(10).opacity(waitingForOpponentBackgroundOpacity))
                        .cornerRadius(10)
                        .onAppear {
                            startWaitingTextAnimation()
                            
                            waitingForOpponentBackgroundOpacity = 0.8
                            withAnimation(
                                .easeInOut(duration: 0.75)
                                .repeatForever(autoreverses: true)
                            ) { waitingForOpponentBackgroundOpacity = 0.65 }
                        }
                        .onDisappear {
                            stopWaitingAnimation()
                            waitingForOpponentBackgroundOpacity = 0.8
                        }
                }
            }

            .onChange(of: geometry.size) { _, newSize in //this is likely not needed as the scene should NOT be changing sizes (only portrait!)
                if newSize.height > newSize.width {
                    if scene == nil {
                        scene = renderScene(size: newSize, hexPgn: latestHexPGN!)
                    } else {
                        scene?.size = newSize
                    }
                    
                    if newSize.height > newSize.width {
                        scene?.scaleMode = .aspectFill
                    } else {
                        scene?.scaleMode = .resizeFill
                    }
                }
            }
            
            .onChange(of: isLocalPlayersTurn) { _, newValue in //_ is the old value //test if true works to remove the initial display!
                updateWaitingBlock(for: newValue)
            }
        }
    }
    
    private func updateWaitingBlock(for isTurn: Bool) {
        if isTurn == false {
            startWaitingTextAnimation()
        } else {
            stopWaitingAnimation()
        }
    }

    private func renderScene(size: CGSize, hexPgn: [UInt8]) -> SKScene {
        //print("scene size:", size)
        let newScene = MessagesGameScene(size: size)
        newScene.gameDelegate = delegate
        newScene.scaleMode = .aspectFill

        newScene.redStatusTextUpdater = { text in
            self.redStatusText = text // update the red status text from the GameScene
        }
        
        newScene.turnStateUpdater = { isTurn in
            self.isLocalPlayersTurn = isTurn
        }
        
        return newScene
    }
    
    private func startWaitingTextAnimation() {
        let baseText = NSLocalizedString("Waiting for opponent", comment: "Waiting text in iMessage")
        let dots = ["..", "...", "."]
        var currentIndex = 0
        
        waitingTimer?.invalidate() // stop any previous timer
        
        waitingTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            waitingForOpponentText = baseText + dots[currentIndex]
            currentIndex = (currentIndex + 1) % dots.count
        }
    }

    private func stopWaitingAnimation() {
        waitingTimer?.invalidate()
        waitingTimer = nil
        //waitingForOpponentText = ""
    }
}
