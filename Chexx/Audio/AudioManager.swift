//
//  AudioManager.swift
//  Chexx
//
//  Created by Sawyer Christensen on 8/9/24.
//

import AVFoundation
import SwiftUI

class AudioManager: ObservableObject {
    var backgroundMusicPlayer: AVAudioPlayer?
    var soundEffectPlayer: AVAudioPlayer?

    func playBackgroundMusic(fileName: String, fileType: String) {
        guard let path = Bundle.main.path(forResource: fileName, ofType: fileType) else {
            print("Background music file not found: \(fileName).\(fileType)")
            return
        }
        let url = URL(fileURLWithPath: path)

        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1 // Loop indefinitely
            backgroundMusicPlayer?.volume = 0.2
            backgroundMusicPlayer?.play()
        } catch {
            print("Could not load background music file: \(error)")
        }
    }

    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
    }

    func playSoundEffect(fileName: String, fileType: String) {
        guard let path = Bundle.main.path(forResource: fileName, ofType: fileType) else {
            print("Sound effect file not found: \(fileName).\(fileType)")
            return
        }
        let url = URL(fileURLWithPath: path)

        do {
            soundEffectPlayer = try AVAudioPlayer(contentsOf: url)
            
            if fileName == "piece_move"{
                soundEffectPlayer?.volume = 0.5
            }
            else {
                soundEffectPlayer?.volume = 0.05
            }
            soundEffectPlayer?.play()
        } catch {
            print("Could not play sound effect: \(error)")
        }
    }
}
