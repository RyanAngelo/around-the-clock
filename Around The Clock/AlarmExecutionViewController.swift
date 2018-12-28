//
//  AlarmConfigViewController.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/11/14.
//  Copyright (c) 2018 Ryan Angelo. All rights reserved.
//

import Cocoa
import CoreData

class AlarmExecutionViewController: NSViewController {
    
    @IBOutlet weak var timelabel: NSTextField!
    var alarmobject: Alarm!
    var mysound: NSSound!
    var audiopath: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timelabel.stringValue=alarmobject.name
        mysound = NSSound(contentsOf: self.getSound(alarmobject), byReference: false)
        mysound?.loops=true
        mysound?.play()
    }
    
    @IBAction func stop_the_alarm (_ sender: AnyObject?) {
        mysound.stop()
        audiopath.stopAccessingSecurityScopedResource()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "stopAlarms"), object: self, userInfo:nil)
        self.dismiss(self)
    }
    
    func getSound(_ Countdown_obj: Alarm) -> URL{
        let fileManager = FileManager.default
        let audiofile: String = alarmobject.audio
        if fileManager.fileExists(atPath: audiofile as String){
            print("File \(audiofile) exists")
            var secaudiodata: Data!
            secaudiodata = UserDefaults.standard.data(forKey: alarmobject.uid as String)
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
            audiopath = URL(fileURLWithPath: Bundle.main.path(forSoundResource: "WakeUpShakeUp")!)
        }
        return audiopath
    }
    
}
