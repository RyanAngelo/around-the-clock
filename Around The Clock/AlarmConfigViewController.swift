//
//  AlarmConfigViewController.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/11/14.
//  Copyright (c) 2018 Ryan Angelo. All rights reserved.
//

import Cocoa
import CoreData

class AlarmConfigViewController: NSViewController {
    
    @IBOutlet weak var timelabel: NSTextField!
    @IBOutlet weak var soundtitle: NSTextField!
    @IBOutlet weak var dismissbutton: NSButton!
    @IBOutlet weak var browsebutton: NSButton!
    @IBOutlet weak var errorlabel: NSTextField!
    
    var alarmobject: Alarm!
    var chosenaudio: String!
    var fileurl: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Alarm Configuration View Controller Has Loaded.");
        chosenaudio=alarmobject.audio
        timelabel.stringValue = alarmobject.name as String
        soundtitle.stringValue = alarmobject.audio as String
    }
    
    @IBAction func openfiledlg (_ sender: AnyObject?)
    {
        let myFiledialog: NSOpenPanel = NSOpenPanel()
        
        myFiledialog.prompt = "Open"
        myFiledialog.worksWhenModal = true
        myFiledialog.allowsMultipleSelection = false
        myFiledialog.canChooseDirectories = false
        myFiledialog.resolvesAliases = true
        myFiledialog.title = "Audio Selection"
        myFiledialog.message = "Please select the audio file you would like to use"
        myFiledialog.runModal()
        
        if myFiledialog.url != nil{
            fileurl = myFiledialog.url
            chosenaudio=fileurl.path as String?
        }
        else{
            errorlabel.stringValue = "Can't open selected file. Please select an audio file." as String
        }
        soundtitle.stringValue = chosenaudio as String
    }
    
    
    @IBAction func selectionsDone(_ sender: AnyObject?) {
        var apsecurity: Data?
        
        //Note: Entitlements for user-selected needs to be read AND write for this not to be nil.
        if fileurl != nil{
            apsecurity=try! fileurl.bookmarkData(options: NSURL.BookmarkCreationOptions.withSecurityScope,includingResourceValuesForKeys: nil, relativeTo: nil)
            
            UserDefaults.standard.set(apsecurity, forKey:alarmobject.uid as String)
            alarmobject.audio=chosenaudio as String
        }
        self.dismiss(self)
    }
}
