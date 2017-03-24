//
//  AlarmViewController.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/1/14.
//  Copyright (c) 2016 Ryan Angelo. All rights reserved.
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

    var isViewVisible: Bool?
    let appDelegate = (NSApplication.shared().delegate as! AppDelegate)
    var managedObjectContext=(NSApplication.shared().delegate as! AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Alarm View Controller Has Loaded.");
        self.timelabel.stringValue="00:00:00"
        
        //Create listeners for the different topics for events that could occur.
        NotificationCenter.default.addObserver(self, selector: #selector(AlarmViewController.bringAlarmWindowUp(_:)), name: NSNotification.Name(rawValue: "alarmExecuting"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AlarmViewController.stopActiveAlarms(_:)), name: NSNotification.Name(rawValue: "stopAlarms"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AlarmViewController.bringcountdownWindowUp(_:)), name: NSNotification.Name(rawValue: "countdownExecuting"), object: nil)
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
            alarm.alarmstate="off"
            alarm.alarmtime=self.changeDay(alarm, timeinterval: alarm.alarmtime.timeIntervalSinceNow).alarmtime
        }
        do {
            try self.managedObjectContext.save()
        } catch _ {
        } //For error handling replace nil with error handler
        self.timetable.reloadData()
    }
    
    override func viewDidAppear() {
        self.isViewVisible=true
    }
    
    override func viewDidDisappear() {
        self.isViewVisible=false
        do {
            try self.managedObjectContext.save()
        } catch _ {
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if (segue.identifier == "AlarmConfiguration"){
            let selectedalarm: [Alarm]=self.alarmArrayController.selectedObjects as! [Alarm]
            let alarm_obj: Alarm = self.getAlarmObject(selectedalarm)!
            let svc = segue.destinationController as! AlarmConfigViewController;
            svc.alarmobject = alarm_obj
        }
        if (segue.identifier == "AlarmExecution"){
            let svc = segue.destinationController as! AlarmExecutionViewController;
            svc.alarmobject = sender as! Alarm
        }
        if (segue.identifier == "CountdownExecution"){
            let svc = segue.destinationController as! CountdownExecutionViewController;
            svc.countdown_obj = sender as! Countdown
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "AlarmConfiguration" &&  !self.alarmArrayController.canRemove{
            print("Can't configure an Alarm. No Alarms exist.")
            return false;
        }
        return true;
    }
    
    func bringAlarmWindowUp(_ notifcation: Notification){
        if self.isViewVisible==true{
            let alarm_obj: Alarm = (notifcation as NSNotification).userInfo!["alarm_obj"] as! Alarm
            self.performSegue(withIdentifier: "AlarmExecution", sender: alarm_obj)
        }
    }
    
    func bringcountdownWindowUp(_ notifcation: Notification){
        if self.isViewVisible==true{
            let countdown_obj: Countdown = (notifcation as NSNotification).userInfo!["countdown_obj"] as! Countdown
            self.performSegue(withIdentifier: "CountdownExecution", sender: countdown_obj)
        }
    }
    
    @IBAction func addAlarmItem(_ sender: AnyObject) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let now = Date()
        let cal = Calendar(identifier: .gregorian)
        let todayStart = cal.startOfDay(for: now)
        let entityDescription=NSEntityDescription.entity(forEntityName: "Alarm", in: self.managedObjectContext)
        
        // Components to calculate end of day
        let components = NSDateComponents()
        components.day = 1
        components.second = -1
        let endOfDay = NSCalendar.current.date(byAdding: components as DateComponents, to: todayStart)

        let myAlarm = Alarm(entity: entityDescription!, insertInto: managedObjectContext)
        myAlarm.setValue(endOfDay, forKey: "alarmtime")
        myAlarm.setValue("Alarm", forKey: "name")
        myAlarm.setValue("off", forKey: "alarmstate")
        let uid = UUID().uuidString //create unique user identifier
        myAlarm.setValue(uid, forKey:"uid")
        self.alarmArrayController.addObject(myAlarm)
        do {
            try self.managedObjectContext.save()
        } catch _ {
        } //For error handling replace nil with error handler
        self.timetable.reloadData()
        self.newSelection(sender)
    }
    
    @IBAction func deleteAlarm(_ sender: AnyObject) {
        if alarmArrayController.canRemove==true{ //confirm there are actually more alarms to view
            let selectedalarm: AnyObject=self.alarmArrayController.selectedObjects as AnyObject
            selectedalarm.setValue("off", forKey: "alarmstate")
            //dispatch UI task on the main queue
            let selected_row=self.timetable.selectedRow
            self.alarmArrayController.remove(atArrangedObjectIndex: selected_row)
            self.timelabel.stringValue="00:00:00"
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
        if alarmArrayController.canRemove==true{
            let selectedalarm: [Alarm]=self.alarmArrayController.selectedObjects as! [Alarm]
            let alarm_obj: Alarm = self.getAlarmObject(selectedalarm)!
            _=changeDay(alarm_obj, timeinterval: alarm_obj.alarmtime.timeIntervalSinceNow)
            if alarm_obj.alarmstate as NSString == "off"{
                alarm_obj.alarmstate="on"
                stopalarm_btn.isHidden=false
                startalarm.isHidden=true
                alarmtimechoice.isEnabled=false
                Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(AlarmViewController.runAlarm(_:)), userInfo: alarm_obj, repeats: true)
            }
            do {
                try self.managedObjectContext.save()
            } catch _ {
            }
            self.timetable.reloadData()
        }
    }
    
    @IBAction func stopAlarm(_ sender: AnyObject) {
        if alarmArrayController.canRemove==true{
            let selectedalarm: [Alarm]=self.alarmArrayController.selectedObjects as! [Alarm]
            let alarm_obj: Alarm = self.getAlarmObject(selectedalarm)!
            if alarm_obj.alarmstate == "on" || alarm_obj.alarmstate=="activated"{
                alarm_obj.alarmstate="off"
                stopalarm_btn.isHidden=true
                startalarm.isHidden=false
                alarmtimechoice.isEnabled=true
            }
            self.timelabel.stringValue="00:00:00"
            do {
                try self.managedObjectContext.save()
            } catch _ {
            }
            self.timetable.reloadData()
        }
    }
    
    func runAlarm(_ timer: Timer) {
        let alarm_obj = timer.userInfo as! Alarm
        
        if alarm_obj.alarmstate=="off"{
            timer.invalidate()
        }
        
        let alarmtime: Date = alarm_obj.alarmtime as Date
        let identifier: String = alarm_obj.uid
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        var timeinterval = TimeInterval()
        
        
        if alarm_obj.alarmstate=="on"{
            let currentselection: Alarm=self.alarmArrayController.selectedObjects[0] as! Alarm
            let currentuid = currentselection.uid
            timeinterval=alarmtime.timeIntervalSinceNow
            if timeinterval.sign == .minus { //Alarm is going off
                alarm_obj.alarmstate="activated"
                self.timelabel.stringValue="00:00:00"
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
    
    @IBAction func newSelection(_ sender: AnyObject) {
        if alarmArrayController.canRemove==true{ //confirm there are actually more alarms to view
            let selectedalarm: Alarm=self.alarmArrayController.selectedObjects[0] as! Alarm
            let alarmstate = selectedalarm.alarmstate
            if alarmstate == "on" || alarmstate == "activated"{
                stopalarm_btn.isHidden=false
                startalarm.isHidden=true
            }
            if alarmstate == "off"{
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
        let selectedalarm: [Alarm]=self.alarmArrayController.selectedObjects as! [Alarm]
        let alarm_obj: Alarm = self.getAlarmObject(selectedalarm)!
        _=changeDay(alarm_obj, timeinterval: alarm_obj.alarmtime.timeIntervalSinceNow)
    }
    
    //We always want the alarm to be for a future time. So this checks to make sure that the alarm is 
    //being set such that when the user starts the alarm, the alarm is always for the next time that time
    //is applicable. This decides whether the alarm should be today or tomorrow.
    func changeDay(_ alarm_obj: Alarm, timeinterval: TimeInterval) -> (alarmtime:Date, timeinterval:TimeInterval){
        var returntimeinterval = timeinterval
        let alarmtime: Date = alarm_obj.alarmtime as Date
        let oneday: TimeInterval = TimeInterval(86400)
        var daystosubtract = oneday
        if timeinterval.sign == .minus{
            if abs(timeinterval)/oneday > 1{
                daystosubtract=(abs(timeinterval)/oneday)*oneday
            }
            let new_date: Date=alarmtime.addingTimeInterval(daystosubtract) //add 24 hours to the alarm
            alarm_obj.alarmtime=new_date
            returntimeinterval=alarm_obj.alarmtime.timeIntervalSinceNow
            do {
                try self.managedObjectContext.save()
            } catch _ {
            } //For error handling replace nil with error handler
        }
        if(timeinterval >= oneday){ //If you are more than one day ahead in the future...
            if timeinterval/oneday >= 2{
                daystosubtract=(timeinterval/oneday)-(timeinterval.truncatingRemainder(dividingBy: oneday))
                daystosubtract=daystosubtract*oneday
            }
            let new_date: Date=alarmtime.addingTimeInterval(-daystosubtract) //subtract amt
            alarm_obj.alarmtime=new_date
            returntimeinterval=alarm_obj.alarmtime.timeIntervalSinceNow
            do {
                try self.managedObjectContext.save()
            } catch _ {
            } //For error handling replace nil with error handler
        }
        return (alarm_obj.alarmtime as Date, returntimeinterval)
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
    
    func stopActiveAlarms(_ notifcation: Notification){
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
            alarm.alarmstate="off"
            let timeinterval=alarm.alarmtime.timeIntervalSinceNow
            alarm.alarmtime=self.changeDay(alarm, timeinterval:timeinterval).alarmtime
            if alarm.uid as String==currentuid{
              self.timelabel.stringValue="00:00:00"
            }
            do {
                try self.managedObjectContext.save()
            } catch _ {
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


