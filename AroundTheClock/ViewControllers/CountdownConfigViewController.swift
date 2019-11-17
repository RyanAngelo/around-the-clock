//
//  CountdownConfigViewController.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/11/14.
//  Copyright (c) 2018 Ryan Angelo. All rights reserved.
//

import Cocoa
import CoreData

class CountdownConfigViewController: NSViewController {
    
    @IBOutlet weak var timelabel: NSTextField!
    @IBOutlet weak var soundtitle: NSTextField!
    @IBOutlet weak var dismissbutton: NSButton!
    @IBOutlet weak var browsebutton: NSButton!
    @IBOutlet weak var errorlabel: NSTextField!
    
    var countdown_obj: Countdown!
    var chosenaudio: String!
    var fileurl: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Countdown Configuration View Controller Has Loaded.");
        chosenaudio=countdown_obj.audio
        timelabel.stringValue = countdown_obj.name
        soundtitle.stringValue = countdown_obj.audio
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
        chosenaudio=fileurl.path
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
            
            UserDefaults.standard.set(apsecurity, forKey:countdown_obj.uid)
            countdown_obj.audio=chosenaudio as String
        }
        self.dismiss(self)
    }
    
}
