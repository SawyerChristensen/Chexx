//
//  GameView.swift
//  Chexx
//
//  Created by Sawyer Christensen on 8/8/24.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    @State var isVsCPU: Bool = false
    @State var isTabletopMode: Bool = false

    var scene: SKScene {
        let scene = GameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .aspectFill
        scene.isVsCPU = isVsCPU // Pass the vs CPU mode
        scene.isTabletopMode = isTabletopMode // Pass the tabletop mode
        return scene
    }

    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
            .onAppear {
                // Additional setup if needed
            }
    }
}
