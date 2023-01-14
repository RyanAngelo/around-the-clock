//
//  AudioPlayer.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/26/22.
//

import Foundation
import AVFoundation

enum AudioFiles: String, CaseIterable, Identifiable {
    case None = "None"
    case SimpleBells = "Simple-Bells"
    case SimpleHorn = "Simple-Horn"
    case SimpleBeep = "Simple-Beep"
    var id: RawValue { rawValue }
}

class AudioController {
    
    var player: AVAudioPlayer?

    init() {}
    
    func playSound(soundResource: String) {
        guard let path = Bundle.main.path(forResource: soundResource, ofType:"mp3") else {
            return }
        let url = URL(fileURLWithPath: path)
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.prepareToPlay()
            player?.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func stopSound() {
        player?.stop()
    }
    
}
