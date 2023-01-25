//
//  SoundManager.swift
//  LadyBug
//
//  Created by hailey macbook on 2023/01/25.
//

import Foundation
import AVFAudio

final class SoundManager {
    static private var player: AVAudioPlayer?
    
    static func play(fileName: String) {
        if let url = Bundle.main.url(forResource: fileName, withExtension: nil) {
            player = try? AVAudioPlayer(contentsOf: url)
            player?.play()
        }
    }
    
    static func pause() {
        player?.pause()
    }
    
    static func stop() {
        player?.stop()
    }
    
    static func resume() {
        player?.play()
    }
}
