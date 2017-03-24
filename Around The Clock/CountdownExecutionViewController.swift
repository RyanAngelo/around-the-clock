//
//  CountdownConfigViewController.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/11/14.
//  Copyright (c) 2016 Ryan Angelo. All rights reserved.
//

import CoreData
import AppKit
import AVFoundation

class CountdownExecutionViewController: NSViewController {
    
    @IBOutlet weak var timelabel: NSTextField!
    var countdown_obj: Countdown!
    var mysound: NSSound!
    var audiopath: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timelabel.stringValue=countdown_obj.name
        mysound = NSSound(contentsOf: self.getSound(countdown_obj), byReference: false)
        mysound?.loops=true
        mysound?.play()
    }
    
    @IBAction func stopCountdown (_ sender: AnyObject?) {
        mysound?.stop()
        audiopath.stopAccessingSecurityScopedResource()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "stopCountdowns"), object: self, userInfo:nil)
        self.dismiss(self)
    }
    
    func getSound(_ Countdown_obj: Countdown) -> URL{
        let fileManager = FileManager.default
        let audiofile: String = Countdown_obj.audio
        if fileManager.fileExists(atPath: audiofile as String){
            print("File \(audiofile) exists")
            var secaudiodata: Data!
            secaudiodata = UserDefaults.standard.data(forKey: countdown_obj.uid)
            var isStale: ObjCBool = false
            do {
                audiopath = try (NSURL(
                    resolvingBookmarkData: secaudiodata!,
                    options: NSURL.BookmarkResolutionOptions.withSecurityScope,
                    relativeTo: nil,
                    bookmarkDataIsStale: &isStale) as URL)
            } catch {
                audiopath = nil
            }
            // Regain the access rights
            _=audiopath!.startAccessingSecurityScopedResource()
            
        }
        else{
            print("File \(audiofile) does not exist. Using default")
            audiopath = URL(fileURLWithPath: Bundle.main.path(forSoundResource: "WakeTheThump")!)
        }
        return audiopath
    }
    
}
