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
    //@State var variant: String
    //@State private var sceneSize: CGSize = UIScreen.main.bounds.size

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(UIColor(hex: "#262626")).edgesIgnoringSafeArea(.all)
                
                SpriteView(scene: createScene(size: geometry.size))
                    .ignoresSafeArea()
                    //.onAppear {
                    //    sceneSize = geometry.size
                   // }
                    .onChange(of: geometry.size) { _, newSize in
                    //    sceneSize = newSize
                        updateSceneSize(newSize)
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
        }
    }

    private func createScene(size: CGSize) -> SKScene {
        let scene = GameScene(size: size, isVsCPU: isVsCPU, isPassAndPlay: isPassAndPlay)
        scene.scaleMode = .aspectFill
        //scene.anchorPoint = CGPoint(x: 0.5, y: 0.5) //written in gameScene
        scene.isVsCPU = isVsCPU // Pass the vs CPU mode
        //scene.variant = variant
        scene.isPassAndPlay = isPassAndPlay // Pass the tabletop mode
        scene.redStatusTextUpdater = { text in
            self.redStatusText = text // Update the status text from the GameScene
        }
        scene.whiteStatusTextUpdater = { text in
            self.whiteStatusText = text // Update the white status text from the GameScene
        }
        return scene
    }

    private func updateSceneSize(_ newSize: CGSize) {
        if let skView = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let rootViewController = skView.windows.first?.rootViewController as? SKView {
            if let scene = rootViewController.scene as? GameScene {
                scene.size = newSize
                scene.scaleMode = .aspectFill
                rootViewController.presentScene(scene)
            }
        }
    }
}
