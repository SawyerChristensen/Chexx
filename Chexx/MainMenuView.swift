//
//  MainMenuView.swift
//  Chexx
//
//  Created by Sawyer Christensen on 7/10/24.
//

import SwiftUI

struct MainMenuView: View {
    var body: some View {
        VStack {
            Text("Main Menu")
                .font(.largeTitle)
                .padding()

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
                Text("Start Game")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}
