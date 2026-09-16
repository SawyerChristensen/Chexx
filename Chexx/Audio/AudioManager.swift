//
//  AudioManager.swift
//  Chexx
//
//  Created by Sawyer Christensen on 8/9/24.
//

import AVFoundation

class AudioManager: ObservableObject {
    var backgroundMusicPlayer: AVAudioPlayer?
    /// Retains the most recently, on-demand-loaded effect (e.g. the end-of-game stinger) for the
    /// duration of its playback — see the fallback branch of `playSoundEffect`.
    private var oneShotPlayer: AVAudioPlayer?
    /// A small pool of prepared players per short, frequently-repeated SFX, keyed by file name —
    /// see `init`. A single player per effect would have `check` (fired right after `piece_move`
    /// on every checking move, see `GameScene.updateGameStatusUI`) cut itself or its neighbor off
    /// mid-playback; a round-robin pool, mirroring PocketPoker's `cardFlipPlayers`, avoids that.
    private var soundEffectPlayers: [String: [AVAudioPlayer]] = [:]
    private var nextSoundEffectVoice: [String: Int] = [:]
    private static let soundEffectVoicesPerSound = 2

    init() {
        preloadSoundEffect(fileName: "piece_move", fileType: "caf")
        preloadSoundEffect(fileName: "check", fileType: "caf")
    }

    private func preloadSoundEffect(fileName: String, fileType: String) {
        guard let path = Bundle.main.path(forResource: fileName, ofType: fileType) else { return }
        let url = URL(fileURLWithPath: path)
        for _ in 0..<Self.soundEffectVoicesPerSound {
            guard let player = try? AVAudioPlayer(contentsOf: url) else { break }
            player.volume = 0.1
            player.prepareToPlay()
            soundEffectPlayers[fileName, default: []].append(player)
        }
    }

    func playBackgroundMusic(fileName: String, fileType: String) {
        #if canImport(UIKit)
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
        #endif

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

    /// Plays a preloaded effect (see `init`) by resetting its playhead, or falls back to loading
    /// one on demand for anything not preloaded — the one-shot end-of-game stingers.
    func playSoundEffect(fileName: String, fileType: String) {
        if let players = soundEffectPlayers[fileName], !players.isEmpty {
            let voice = nextSoundEffectVoice[fileName, default: 0]
            nextSoundEffectVoice[fileName] = voice + 1
            let player = players[voice % players.count]
            player.currentTime = 0
            player.play()
            return
        }

        guard let path = Bundle.main.path(forResource: fileName, ofType: fileType) else { return }
        let url = URL(fileURLWithPath: path)

        do {
            oneShotPlayer = try AVAudioPlayer(contentsOf: url)
            oneShotPlayer?.volume = 0.1
            oneShotPlayer?.play()
        } catch {
            //print("Could not play sound effect: \(error)")
        }
    }
}
