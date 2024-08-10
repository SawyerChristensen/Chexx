//
//  AudioManager.swift
//  Chexx
//
//  Created by Sawyer Christensen on 8/9/24.
//

import AVFoundation
import SwiftUI

class AudioManager: ObservableObject {
    var audioPlayer: AVAudioPlayer?

    init() {
        setupAudioPlayer()
    }

    private func setupAudioPlayer() {
        guard let path = Bundle.main.path(forResource: "carmen-habanera", ofType: "mp3") else {
            return
        }

        let url = URL(fileURLWithPath: path)

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.volume = 0.3
        } catch {
            print("Could not load file")
        }
    }

    func play() {
        audioPlayer?.play()
    }

    func stop() {
        audioPlayer?.stop()
    }
}
