//
//  CountdownViewController.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/1/14.
//  Copyright (c) 2016 Ryan Angelo. All rights reserved.
//

import Cocoa
import CoreData

class CountdownViewController: NSViewController {
    
    @IBOutlet var hourstext: NSTextField!
    @IBOutlet var minstext: NSTextField!
    @IBOutlet var secondstext: NSTextField!
    
    @IBOutlet weak var timelabel: NSTextField!
    @IBOutlet weak var timetable: NSTableView!
    @IBOutlet var countdownArrayController: NSArrayController!
    @IBOutlet weak var startcountdown: NSButton!
    @IBOutlet weak var resetcountdown: NSButton!
    @IBOutlet weak var pausecountdown: NSButton!
    
    let appDelegate = (NSApplication.shared.delegate as! AppDelegate)
    
    @objc var managedObjectContext=(NSApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Countdown View Controller Has Loaded.");
        self.timelabel.stringValue="00:00:00"
        
        //Create listeners for the different topics for events that could occur.
        NotificationCenter.default.addObserver(self, selector: #selector(CountdownViewController.stopActivecountdowns(_:)), name: NSNotification.Name(rawValue: "stopCountdowns"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CountdownViewController.bringAlarmWindowUp(_:)), name: NSNotification.Name(rawValue: "alarmExecuting"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CountdownViewController.bringcountdownWindowUp(_:)), name: NSNotification.Name(rawValue: "countdownExecuting"), object: nil)

        let watchrequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Countdown")
        var results = [NSManagedObject]()

        do{
            results = try managedObjectContext.fetch(watchrequest) as! [NSManagedObject]
            
        }
        catch {
            print("Unable to load existing Countdowns.")
        }
        for result in results{
            let countdown:Countdown=result as! Countdown
            countdown.countdownstate="off"
        }
        
        do {
            try self.managedObjectContext.save()
        } catch _ {
        } //For error handling replace nil with error handler
        self.timetable.reloadData()

    }
    
    override func viewDidAppear() {
        newSelection(self)
    }
    
    override func viewDidDisappear() {
        do {
            try self.managedObjectContext.save()
        } catch _ {
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if (segue.identifier!.rawValue == "CountdownConfiguration"){
            let selectedcountdown: [Countdown]=self.countdownArrayController.selectedObjects as! [Countdown]
            let countdown_obj: Countdown = self.getcountdownObject(selectedcountdown)!
            let svc = segue.destinationController as! CountdownConfigViewController;
            svc.countdown_obj = countdown_obj
        }
        if (segue.identifier!.rawValue == "CountdownExecution"){
            let svc = segue.destinationController as! CountdownExecutionViewController;
            svc.countdown_obj = sender as! Countdown
        }
        if (segue.identifier!.rawValue == "AlarmExecution"){
            let svc = segue.destinationController as! AlarmExecutionViewController;
            svc.alarmobject = sender as! Alarm
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: NSStoryboardSegue.Identifier, sender: Any?) -> Bool {
        if identifier.rawValue == "CountdownConfiguration" &&  !self.countdownArrayController.canRemove{
            print("Can't configure a Countdown. No Countdowns exist.")
            return false;
        }
        return true;
    }
    
    
    @objc func bringcountdownWindowUp(_ notification: Notification){
        if self.view.window != nil || ((self.view.window != nil) && self.appDelegate.mainWindow.isMiniaturized){
            let countdown_obj: Countdown = (notification as NSNotification).userInfo!["countdown_obj"] as! Countdown
            self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "CountdownExecution"), sender: countdown_obj)
        }
    }
    
    @objc func bringAlarmWindowUp(_ notification: Notification){
        if self.view.window != nil || ((self.view.window != nil) && self.appDelegate.mainWindow.isMiniaturized){
            let alarm_obj: Alarm = (notification as NSNotification).userInfo!["alarm_obj"] as! Alarm
            self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "AlarmExecution"), sender: alarm_obj)
        }
    }
    
    @IBAction func addcountdownItem(_ sender: AnyObject) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let entityDescription=NSEntityDescription.entity(forEntityName: "Countdown", in: self.managedObjectContext)
        
        let mycountdown = Countdown(entity: entityDescription!, insertInto: managedObjectContext)
        
        self.hourstext.integerValue=0
        self.minstext.integerValue=0
        self.secondstext.integerValue=0
        
        let hour=self.hourstext.integerValue
        let min=self.minstext.integerValue
        let second=self.secondstext.integerValue
        let startcountdowntime=Float((hour*60*60)+(min*60)+second)
        
        mycountdown.setValue(startcountdowntime, forKey: "startcountdowntime")
        mycountdown.setValue(startcountdowntime, forKey: "countdowntime")
        mycountdown.setValue("Countdown", forKey: "name")
        mycountdown.setValue("off", forKey: "countdownstate")
        let uid = UUID().uuidString //create unique user identifier
        mycountdown.setValue(uid, forKey:"uid")
        self.countdownArrayController.addObject(mycountdown)
        do {
            try self.managedObjectContext.save()
        } catch _ {
        } //For error handling replace nil with error handler
        self.timetable.reloadData()
        self.newSelection(sender)
    }
    
    @IBAction func deletecountdown(_ sender: AnyObject) {
        if countdownArrayController.canRemove==true{ //confirm there are actually more countdowns to view
            let selectedcountdown: Countdown=self.countdownArrayController.selectedObjects[0] as! Countdown
            selectedcountdown.countdownstate="off"
            //dispatch UI task on the main queue
            let selected_row=self.timetable.selectedRow
            self.countdownArrayController.remove(atArrangedObjectIndex: selected_row)
            self.timelabel.stringValue="00:00:00"
            self.timetable.reloadData()
            self.newSelection(sender)
        }
    }
    
    @IBAction func updateinformation(_ sender: AnyObject) {
        if countdownArrayController.canRemove==true{
            let selectedcountdown: [Countdown]=self.countdownArrayController.selectedObjects as! [Countdown]
            let countdown_obj: Countdown = self.getcountdownObject(selectedcountdown)!
            if countdown_obj.countdownstate=="off" || countdown_obj.countdownstate=="paused"{
                var strHours: String
                var strMinutes: String
                var strSeconds: String
                let hour=self.hourstext.integerValue
                let min=self.minstext.integerValue
                let second=self.secondstext.integerValue
                let startcountdowntime=Int((hour*60*60)+(min*60)+second)
                countdown_obj.countdowntime=startcountdowntime
                countdown_obj.startcountdowntime=startcountdowntime
                let strFormat = self.calculateDisplayTime(countdown_obj.countdowntime)
                strHours=strFormat.strHours as String
                strMinutes=strFormat.strMinutes as String
                strSeconds=strFormat.strSeconds as String
                //dispatch UI task on the main queue
                DispatchQueue.main.async {
                    self.timelabel.stringValue="\(strHours):\(strMinutes):\(strSeconds)"
                    do {
                        try self.managedObjectContext.save()
                    } catch _ {
                    }
                }
            }
        }
    
    }

    @IBAction func startcountdown(_ sender: AnyObject) {
        if countdownArrayController.canRemove==true{
            let selectedcountdown: [Countdown]=self.countdownArrayController.selectedObjects as! [Countdown]
            let countdown_obj: Countdown = self.getcountdownObject(selectedcountdown)!
            if countdown_obj.countdownstate as NSString == "off" || countdown_obj.countdownstate == "paused"{
                if countdown_obj.countdownstate as NSString == "off"{
                    let hour=self.hourstext.integerValue
                    let min=self.minstext.integerValue
                    let second=self.secondstext.integerValue
                    let startcountdowntime=Int((hour*60*60)+(min*60)+second)
                    countdown_obj.countdowntime=startcountdowntime
                    countdown_obj.startcountdowntime=startcountdowntime
                }
                countdown_obj.countdownstate="on"
                resetcountdown.isHidden=false
                pausecountdown.isHidden=false
                hourstext.isEnabled=false
                minstext.isEnabled=false
                secondstext.isEnabled=false
                startcountdown.isHidden=true
                Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(CountdownViewController.runcountdown(_:)), userInfo: countdown_obj, repeats: true)
            }
            do {
                try self.managedObjectContext.save()
            } catch _ {
            }
            self.timetable.reloadData()
        }
    }
    
    @IBAction func resetcountdown(_ sender: AnyObject) {
        if countdownArrayController.canRemove==true{
            let selectedcountdown: [Countdown]=self.countdownArrayController.selectedObjects as! [Countdown]
            let countdown_obj: Countdown = self.getcountdownObject(selectedcountdown)!
            if countdown_obj.countdownstate == "on" || countdown_obj.countdownstate=="activated" || countdown_obj.countdownstate == "paused"{
                countdown_obj.countdownstate="off"
                resetcountdown.isHidden=true
                pausecountdown.isHidden=true
                startcountdown.isHidden=false
                hourstext.isEnabled=true
                minstext.isEnabled=true
                secondstext.isEnabled=true
            }
            self.timelabel.stringValue="00:00:00"
            countdown_obj.countdowntime=countdown_obj.startcountdowntime
            do {
                try self.managedObjectContext.save()
            } catch _ {
            }
            self.timetable.reloadData()
        }
    }
    
    @IBAction func pausecountdown(_ sender: AnyObject) {
        if countdownArrayController.canRemove==true{
            let selectedcountdown: [Countdown] = self.countdownArrayController.selectedObjects as! [Countdown]
            let countdown_obj: Countdown = self.getcountdownObject(selectedcountdown)!
            if countdown_obj.countdownstate == "on" {
                countdown_obj.countdownstate="paused"
                resetcountdown.isHidden=false
                startcountdown.isHidden=false
                pausecountdown.isHidden=true
                hourstext.isEnabled=false
                minstext.isEnabled=false
                secondstext.isEnabled=false
            }
            do {
                try self.managedObjectContext.save()
            } catch _ {
            }
            self.timetable.reloadData()
        }
    }
    
    @objc func runcountdown(_ timer: Timer) {
        let countdown_obj = timer.userInfo as! Countdown
        
        if countdown_obj.countdownstate=="off" || countdown_obj.countdownstate=="paused"{
            timer.invalidate()
        }
        
        let identifier: String = countdown_obj.uid
        
        if countdown_obj.countdownstate=="on"{
            let currentselection: [Countdown] = self.countdownArrayController.selectedObjects as! [Countdown]
            let currentuid: String = currentselection[0].value(forKey: "uid") as! String
            countdown_obj.countdowntime = countdown_obj.countdowntime-1
            if countdown_obj.countdowntime <= 0 { //countdown is going off
                countdown_obj.countdownstate="activated"
                self.timelabel.stringValue="00:00:00"
                countdown_obj.countdowntime=0
                NotificationCenter.default.post(name: Notification.Name(rawValue: "countdownExecuting"), object: self, userInfo:["countdown_obj":countdown_obj])
            }
            if currentuid == identifier{
                var strHours="00"
                var strMinutes="00"
                var strSeconds="00"
                if countdown_obj.countdowntime > 0{
                    let strFormat = self.calculateDisplayTime(countdown_obj.countdowntime)
                    strHours=strFormat.strHours as String
                    strMinutes=strFormat.strMinutes as String
                    strSeconds=strFormat.strSeconds as String
                }
                //dispatch UI task on the main queue
                DispatchQueue.main.async {
                    self.timelabel.stringValue="\(strHours):\(strMinutes):\(strSeconds)"
                }
            }
        }
    }
    
    @IBAction func newSelection(_ sender: AnyObject) {
        if countdownArrayController.canRemove==true{
            let selectedcountdown: [Countdown]=self.countdownArrayController.selectedObjects as! [Countdown]
            if selectedcountdown.count==0{
                self.countdownArrayController.setSelectionIndex(0)
            }
            let countdownstate = selectedcountdown[0].value(forKey: "countdownstate") as! String
            if countdownstate == "on" || countdownstate == "activated"{
                resetcountdown.isHidden=false
                startcountdown.isHidden=true
                pausecountdown.isHidden=false
                minstext.isEnabled=false
                secondstext.isEnabled=false
                hourstext.isEnabled=false
                
                updateTextBoxes(selectedcountdown)
                
            }
            if countdownstate == "off"{
                resetcountdown.isHidden=true
                startcountdown.isHidden=false
                pausecountdown.isHidden=true
                hourstext.isEnabled=true
                minstext.isEnabled=true
                secondstext.isEnabled=true
                
                DispatchQueue.main.async {
                    self.timelabel.stringValue="00:00:00"
                }
                
                updateTextBoxes(selectedcountdown)

            }
            if countdownstate == "paused"{
                resetcountdown.isHidden=false
                startcountdown.isHidden=false
                pausecountdown.isHidden=true
                hourstext.isEnabled=false
                minstext.isEnabled=false
                secondstext.isEnabled=false
                
                DispatchQueue.main.async {
                    self.timelabel.stringValue="00:00:00"
                }

                updateTextBoxes(selectedcountdown)
            }
        }
    }
    
    func updateTextBoxes(_ selectedcountdown: [Countdown]){
        let countdowntime: Int=selectedcountdown[0].value(forKey: "startcountdowntime") as! Int
        self.hourstext.integerValue=(countdowntime/60)/60
        self.minstext.integerValue=(countdowntime-self.hourstext.integerValue*60*60)/60
        self.secondstext.integerValue=countdowntime-((self.hourstext.integerValue*60*60)+(self.minstext.integerValue*60))
    }
    
    func calculateDisplayTime(_ ptimeinterval: Int) -> (strHours: NSString, strMinutes: NSString, strSeconds: NSString){
        var hours=UInt16(0)
        var minutes=UInt16(0)
        var seconds=UInt16(0)
        var timeinterval: Int = ptimeinterval
        if (timeinterval == 0 || timeinterval < 0) {
            hours=0
            minutes=0
            seconds=0
        }else{
            hours=UInt16((timeinterval/60)/60)
            timeinterval-=Int(hours)*60*60
            minutes=UInt16(timeinterval/60)
            timeinterval-=Int(minutes)*60
            seconds=UInt16(timeinterval)
        }
        let strHours=hours > 9 ? String(hours):"0"+String(hours)
        let strMinutes=minutes > 9 ? String(minutes):"0"+String(minutes)
        let strSeconds=seconds > 9 ? String(seconds):"0"+String(seconds)
        
        return (strHours as NSString, strMinutes as NSString, strSeconds as NSString)
    }
    
    func getcountdownObject(_ selectedcountdown: [Countdown]) -> Countdown?{
        let identifier: String = selectedcountdown[0].value(forKey: "uid") as! String
        let countdownrequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Countdown")
        
        countdownrequest.returnsDistinctResults = true
        countdownrequest.returnsObjectsAsFaults = false
        countdownrequest.predicate = NSPredicate(format: "uid=%@", identifier)
        var countdown_obj: Countdown
        var results = [NSManagedObject]()
        do{
            results = try managedObjectContext.fetch(countdownrequest) as! [NSManagedObject]
            
        }
        catch {
            print("Unable to load existing stopwatches.")
        }
        if results.count == 1{
            countdown_obj = results[0] as! Countdown
            return countdown_obj
        }
        else{
            return nil
        }
    }
    
    @objc func stopActivecountdowns(_ notifcation: Notification){
        let currentselection: [Countdown]=self.countdownArrayController.selectedObjects as! [Countdown]
        let currentuid: NSString = currentselection[0].value(forKey: "uid") as! NSString
        let countdownrequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Countdown")
        countdownrequest.returnsDistinctResults = true
        countdownrequest.returnsObjectsAsFaults = false
        countdownrequest.predicate = NSPredicate(format: "countdownstate='activated'")
        var results = [NSManagedObject]()
        do{
            results = try managedObjectContext.fetch(countdownrequest) as! [NSManagedObject]
            
        }
        catch {
            print("Unable to load existing stopwatches.")
        }

        for result in results{
            let countdown = result as! Countdown
            countdown.countdownstate="off"
            countdown.countdowntime=countdown.startcountdowntime
            if countdown.uid==currentuid as String{
                self.timelabel.stringValue="00:00:00"
            }
        }
        self.newSelection(self)
        do {
            try self.managedObjectContext.save()
        } catch _ {
        }
        self.timetable.reloadData()
    }
    
    
}


