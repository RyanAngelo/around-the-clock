//
//  AlarmViewController.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/1/14.
//  Copyright (c) 2018 Ryan Angelo. All rights reserved.
//

import Cocoa
import CoreData
import AVFoundation

class AlarmViewController: NSViewController {
    
    @IBOutlet weak var alarmtimechoice: NSDatePicker!
    @IBOutlet weak var timelabel: NSTextField!
    @IBOutlet weak var timetable: NSTableView!
    @IBOutlet var alarmArrayController: NSArrayController!
    @IBOutlet weak var startalarm: NSButton!
    @IBOutlet weak var stopalarm_btn: NSButton!
    @IBOutlet weak var addalarm_btn: NSButton!

    let appDelegate = (NSApplication.shared.delegate as! AppDelegate)
    @objc var managedObjectContext=(NSApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Alarm View Controller Has Loaded.");
        
        DispatchQueue.main.async {
            self.timelabel.stringValue="00:00:00"
        }
        
        //Create listeners for the different topics for events that could occur.
        NotificationCenter.default.addObserver(self, selector: #selector(AlarmViewController.bringAlarmWindowUp(_:)), name: NSNotification.Name(rawValue: "alarmExecuting"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AlarmViewController.bringcountdownWindowUp(_:)), name: NSNotification.Name(rawValue: "countdownExecuting"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AlarmViewController.stopActiveAlarms(_:)), name: NSNotification.Name(rawValue: "stopAlarms"), object: nil)
        
        let alarmrequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alarm")
        var results = [NSManagedObject]()

        do{
            results = try managedObjectContext.fetch(alarmrequest) as! [NSManagedObject]
            
        }
        catch {
            print("Unable to load existing Countdowns.")
        }
        for result in results{
            let alarm:Alarm=result as! Alarm
            alarm.setState(state: "off")
            alarm.changeDay()
        }
       self.saveAndReload()
    }
    
    override func viewDidAppear() {
    }
    
    override func viewDidDisappear() {
        do {
            try self.managedObjectContext.save()
        } catch _ {
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if (segue.identifier! == "AlarmConfiguration"){
            let selectedalarm: [Alarm]=self.alarmArrayController.selectedObjects as! [Alarm]
            let alarm_obj: Alarm = self.getAlarmObject(selectedalarm)!
            let svc = segue.destinationController as! AlarmConfigViewController;
            svc.alarmobject = alarm_obj
        }
        if (segue.identifier! == "AlarmExecution"){
            let svc = segue.destinationController as! AlarmExecutionViewController;
            svc.alarmobject = sender as? Alarm
        }
        if (segue.identifier! == "CountdownExecution"){
            let svc = segue.destinationController as! CountdownExecutionViewController;
            svc.countdown_obj = sender as? Countdown
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: NSStoryboardSegue.Identifier, sender: Any?) -> Bool {
        if identifier == "AlarmConfiguration" &&  !self.alarmArrayController.canRemove{
            print("Can't configure an Alarm. No Alarms exist.")
            return false;
        }
        return true;
    }
    
    @objc func bringAlarmWindowUp(_ notifcation: Notification){
        if self.view.window != nil || ((self.view.window != nil) && self.appDelegate.mainWindow.isMiniaturized){
            let alarm_obj: Alarm = (notifcation as NSNotification).userInfo!["alarm_obj"] as! Alarm
            self.performSegue(withIdentifier: "AlarmExecution", sender: alarm_obj)
        }
    }
    
    @objc func bringcountdownWindowUp(_ notifcation: Notification){
        if self.view.window != nil || ((self.view.window != nil) && self.appDelegate.mainWindow.isMiniaturized){
            let countdown_obj: Countdown = (notifcation as NSNotification).userInfo!["countdown_obj"] as! Countdown
            self.performSegue(withIdentifier: "CountdownExecution", sender: countdown_obj)
        }
    }
    
    @IBAction func addAlarmItem(_ sender: AnyObject) {
        self.addAlarm()
        self.newSelection(nil)
    }
    
    func addAlarm() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let today = Date()
        let cal = Calendar.current
        
        let entityDescription=NSEntityDescription.entity(forEntityName: "Alarm", in: self.managedObjectContext)
        
        let hour = cal.component(.hour, from: alarmtimechoice.dateValue)
        let minutes = cal.component(.minute, from: alarmtimechoice.dateValue)
        let seconds = cal.component(.second, from: alarmtimechoice.dateValue)
        
        let chosenDate = cal.date(bySettingHour: hour, minute: minutes, second: seconds, of: today)
        
        let alarm_obj = Alarm(entity: entityDescription!, insertInto: managedObjectContext)
        alarm_obj.alarmtime = chosenDate!
        alarm_obj.name = "Alarm"
        alarm_obj.setState(state: "off")
        let uid = UUID().uuidString //create unique user identifier
        alarm_obj.uid = uid
        self.alarmArrayController.addObject(alarm_obj)
        alarm_obj.changeDay()
        self.saveAndReload()
    }
    
    @IBAction func deleteAlarm(_ sender: AnyObject) {
        if alarmArrayController.canRemove==true{ //confirm there are actually more alarms to view
            let selectedalarm: [Alarm]=self.alarmArrayController.selectedObjects as! [Alarm]
            let alarm_obj: Alarm = self.getAlarmObject(selectedalarm)!
            alarm_obj.setState(state: "off")
            //dispatch UI task on the main queue
            let selected_row=self.timetable.selectedRow
            self.alarmArrayController.remove(atArrangedObjectIndex: selected_row)
            DispatchQueue.main.async {
                self.timelabel.stringValue="00:00:00"
            }
            self.timetable.reloadData()
            self.newSelection(sender)
            if(!self.alarmArrayController.canRemove){
                stopalarm_btn.isHidden=true
                startalarm.isHidden=false
                alarmtimechoice.isEnabled=true
            }
        }
    }
    
    @IBAction func startAlarm(_ sender: AnyObject) {
        // This means the person wants to add and start without clicking "add"
        if(alarmArrayController.selectedObjects.count==0) {
            self.addAlarm()
            self.newSelection(nil)
        }
        if(alarmArrayController.canRemove==true) {
            let selectedalarm: [Alarm]=self.alarmArrayController.selectedObjects as! [Alarm]
            let alarm_obj: Alarm = self.getAlarmObject(selectedalarm)!
            alarm_obj.changeDay()
            if alarm_obj.alarmstate == "off"{
                alarm_obj.setState(state: "on")
                stopalarm_btn.isHidden=false
                startalarm.isHidden=true
                alarmtimechoice.isEnabled=false
                Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(AlarmViewController.runAlarm(_:)), userInfo: alarm_obj, repeats: true)
            }
           self.saveAndReload()
        }
    }
    
    @IBAction func stopAlarm(_ sender: AnyObject) {
        if alarmArrayController.canRemove==true{
            let selectedalarm: [Alarm]=self.alarmArrayController.selectedObjects as! [Alarm]
            let alarm_obj: Alarm = self.getAlarmObject(selectedalarm)!
            if alarm_obj.alarmstate == "on" || alarm_obj.alarmstate=="activated"{
                alarm_obj.setState(state: "off")
                stopalarm_btn.isHidden=true
                startalarm.isHidden=false
                alarmtimechoice.isEnabled=true
            }
            DispatchQueue.main.async {
                self.timelabel.stringValue="00:00:00"
            }
            self.saveAndReload()
        }
    }
    
    @objc func runAlarm(_ timer: Timer) {
        let alarm_obj = timer.userInfo as! Alarm
        if alarm_obj.alarmstate=="off"{
            timer.invalidate()
            return
        }
        else if alarm_obj.alarmstate=="on"{
            let alarmtime: Date = alarm_obj.alarmtime as Date
            let identifier: String = alarm_obj.uid
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            var timeinterval = TimeInterval()
            let currentselection: Alarm=self.alarmArrayController.selectedObjects[0] as! Alarm
            let currentuid = currentselection.uid
            timeinterval=alarmtime.timeIntervalSinceNow
            if timeinterval.sign == .minus { //Alarm is going off
                alarm_obj.setState(state: "activated")
                DispatchQueue.main.async {
                    self.timelabel.stringValue="00:00:00"
                }
                NotificationCenter.default.post(name: Notification.Name(rawValue: "alarmExecuting"), object: self, userInfo:["alarm_obj":alarm_obj])
            }
            if currentuid == identifier as String{
                var strHours="00"
                var strMinutes="00"
                var strSeconds="00"
                if (timeinterval.sign == .minus)==false{
                    let strFormat = self.calculateDisplayTime(timeinterval)
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
    
    @IBAction func newSelection(_ sender: AnyObject?) {
        if alarmArrayController.canRemove==true { //confirm there are actually more alarms to view
            let selectedalarm: Alarm=self.alarmArrayController.selectedObjects[0] as! Alarm
            if selectedalarm.alarmstate == "on" || selectedalarm.alarmstate == "activated"{
                stopalarm_btn.isHidden=false
                startalarm.isHidden=true
            }
            else if selectedalarm.alarmstate == "off"{
                stopalarm_btn.isHidden=true
                startalarm.isHidden=false
                DispatchQueue.main.async {
                    self.timelabel.stringValue="00:00:00"
                }
            }
        }
    }
    
    func calculateDisplayTime(_ ptimeinterval: TimeInterval) -> (strHours: NSString, strMinutes: NSString, strSeconds: NSString){
        var hours=UInt16(0)
        var minutes=UInt16(0)
        var seconds=UInt16(0)
        var timeinterval: TimeInterval = ptimeinterval
        if (timeinterval.isZero || (timeinterval.sign == .minus)) {
            hours=0
            minutes=0
            seconds=0
        }else{
            hours=UInt16((timeinterval/60)/60)
            timeinterval-=TimeInterval(hours)*60*60
            minutes=UInt16(timeinterval/60)
            timeinterval-=TimeInterval(minutes)*60
            seconds=UInt16(timeinterval)
        }
        let strHours=hours > 9 ? String(hours):"0"+String(hours)
        let strMinutes=minutes > 9 ? String(minutes):"0"+String(minutes)
        let strSeconds=seconds > 9 ? String(seconds):"0"+String(seconds)
        
        return (strHours as NSString, strMinutes as NSString, strSeconds as NSString)
    }
    
    //Update when the date picker changes. Check that the date is correct
    //A correct date means either today if the time is still going to happen
    //Or tomorrow if the time has already passed for today.
    @IBAction func checkDay(_ sender: AnyObject){
        if(alarmArrayController.selectedObjects.count>0) {
            let selectedalarm: [Alarm]=self.alarmArrayController.selectedObjects as! [Alarm]
            let alarm_obj: Alarm = self.getAlarmObject(selectedalarm)!
            alarm_obj.changeDay()
        }
    }
    
    func getAlarmObject(_ selectedalarm: [Alarm]) -> Alarm?{
        let identifier: String = selectedalarm[0].value(forKey: "uid") as! String
        let alarmrequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Alarm")
        alarmrequest.returnsDistinctResults = true
        alarmrequest.returnsObjectsAsFaults = false
        alarmrequest.predicate = NSPredicate(format: "uid=%@", identifier)
        var alarm_obj: Alarm
        var results = [NSManagedObject]()
        do{
            results = try managedObjectContext.fetch(alarmrequest) as! [NSManagedObject]
            
        }
        catch {
            print("Unable to load existing alarms.")
        }
        if results.count == 1{
            alarm_obj = results[0] as! Alarm
            return alarm_obj
        }
        else{
            return nil
        }
    }
    
    @objc func stopActiveAlarms(_ notifcation: Notification){
        let currentselection: Alarm=self.alarmArrayController.selectedObjects[0] as! Alarm
        let currentuid = currentselection.uid
        let alarmrequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Alarm")
        alarmrequest.returnsDistinctResults = true
        alarmrequest.returnsObjectsAsFaults = false
        alarmrequest.predicate = NSPredicate(format: "alarmstate='activated'")
        var results = [NSManagedObject]()
        do{
            results = try managedObjectContext.fetch(alarmrequest) as! [NSManagedObject]
            
        }
        catch {
            print("Unable to load existing Alarms.")
        }
        for result in results{
            let alarm = result as! Alarm
            alarm.setState(state: "off")
            alarm.changeDay()
            if alarm.uid as String==currentuid{
                DispatchQueue.main.async {
                    self.timelabel.stringValue="00:00:00"
                }
            }
            do {
                try self.managedObjectContext.save()
            } catch _ {
            }
        }
        self.newSelection(self)
        self.saveAndReload()
    }
    
    func saveAndReload(){
        do {
            try self.managedObjectContext.save()
        } catch _ {
        }
        self.timetable.reloadData()
    }

}


