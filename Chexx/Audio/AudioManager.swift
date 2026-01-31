//
//  AudioManager.swift
//  Chexx
//
//  Created by Sawyer Christensen on 8/9/24.
//

import AVFoundation

class AudioManager: ObservableObject {
    var backgroundMusicPlayer: AVAudioPlayer?
    var soundEffectPlayer: AVAudioPlayer?

    func playBackgroundMusic(fileName: String, fileType: String) {
        // Configure the session to allow mixing with Spotify/Podcasts
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.ambient, options: .mixWithOthers)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }

        // Check if other "important" audio is already playing
        // secondaryAudioShouldBeSilencedHint is true if the user is playing music
        if audioSession.secondaryAudioShouldBeSilencedHint {
            //print("User is already playing audio. Game music muted.")
            return
        }

        guard let path = Bundle.main.path(forResource: fileName, ofType: fileType) else {
            print("Background music file not found: \(fileName).\(fileType)")
            return
        }
        let url = URL(fileURLWithPath: path)

        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1
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
        guard let path = Bundle.main.path(forResource: fileName, ofType: fileType) else { return }
        let url = URL(fileURLWithPath: path)

        do {
            soundEffectPlayer = try AVAudioPlayer(contentsOf: url)
            soundEffectPlayer?.volume = 0.1
            soundEffectPlayer?.play()
        } catch {
            //print("Could not play sound effect: \(error)")
        }
    }
}
