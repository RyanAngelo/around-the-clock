//
//  AudioPlayer.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/26/22.
//

import Foundation
import AVFoundation
var player: AVAudioPlayer?

enum AudioFiles: String, CaseIterable, Identifiable {
    case nuts, cookies, blueberries
    var id: Self { self }
}

class AudioController {
    
    func playSound(soundResource: String) {
        guard let path = Bundle.main.path(forResource: soundResource, ofType:"mp3") else {
            return }
        let url = URL(fileURLWithPath: path)
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
}
