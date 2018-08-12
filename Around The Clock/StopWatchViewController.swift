//
//  StopWatchViewController.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/1/14.
//  Copyright (c) 2018 Ryan Angelo. All rights reserved.
//

import Cocoa

class StopWatchViewController: NSViewController {
    
    @IBOutlet weak var timelabel: NSTextField!
    @IBOutlet var splittimes: NSTextView!
    @IBOutlet weak var timetable: NSTableView!
    @IBOutlet var watchArrayController: NSArrayController!
    @IBOutlet weak var startwatch: NSButton!
    @IBOutlet weak var resetwatch: NSButton!
    @IBOutlet weak var splitbutton: NSButton!
    @IBOutlet weak var lapbutton: NSButton!
    @IBOutlet weak var pausewatch: NSButton!
    
    let appDelegate = (NSApplication.shared.delegate as! AppDelegate)
    @objc var managedObjectContext=(NSApplication.shared.delegate as! AppDelegate).managedObjectContext

    override func awakeFromNib() {
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        print("Stop Watch View Controller Has Loaded.");
    
        NotificationCenter.default.addObserver(self, selector: #selector(StopWatchViewController.bringAlarmWindowUp(_:)), name: NSNotification.Name(rawValue: "alarmExecuting"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(StopWatchViewController.bringcountdownWindowUp(_:)), name: NSNotification.Name(rawValue: "countdownExecuting"), object: nil)
       
        var results = [NSManagedObject]()
        let watchrequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Watch")
        do{
            results = try managedObjectContext.fetch(watchrequest) as! [NSManagedObject]
        }
        catch {
            print("Unable to load existing stopwatches.")
        }
        
        resetwatch.isHidden=false
        startwatch.isHidden=false
        pausewatch.isHidden=true
        splitbutton.isHidden=true
        lapbutton.isHidden=true
        
        for result in results{
            let watch:Watch=result as! Watch
            if watch.watchstate != "off"{
                watch.setState(off: "off")
                watch.elapsedtime="00:00:00.0"
            }
        }
        
        do {
            try self.watchArrayController.fetch(with: nil, merge: false)
        } catch _ {
        }
        if watchArrayController.canRemove{
            let currentselection: [Watch]=self.watchArrayController.selectedObjects as! [Watch]
            DispatchQueue.main.async {
                self.timelabel.stringValue = currentselection[0].value(forKey: "elapsedtime") as! String
            }
        }
        else{
            DispatchQueue.main.async {
                self.timelabel.stringValue="00:00:00.0"
            }
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
        if (segue.identifier!.rawValue == "AlarmExecution"){
            let svc = segue.destinationController as! AlarmExecutionViewController;
            svc.alarmobject = sender as! Alarm
        }
        if (segue.identifier!.rawValue == "CountdownExecution"){
            let svc = segue.destinationController as! CountdownExecutionViewController;
            svc.countdown_obj = sender as! Countdown
        }
    }
    
    @objc func bringAlarmWindowUp(_ notifcation: Notification){
        if self.view.window != nil || ((self.view.window != nil) && self.appDelegate.mainWindow.isMiniaturized){
            let alarm_obj: Alarm = (notifcation as NSNotification).userInfo!["alarm_obj"] as! Alarm
            self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "AlarmExecution"), sender: alarm_obj)
        }
    }
    
    @objc func bringcountdownWindowUp(_ notifcation: Notification){
        if self.view.window != nil || ((self.view.window != nil) && self.appDelegate.mainWindow.isMiniaturized){
            let countdown_obj: Countdown = (notifcation as NSNotification).userInfo!["countdown_obj"] as! Countdown
            self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "CountdownExecution"), sender: countdown_obj)
        }
    }
    
    @IBAction func addWatchItem(_ sender: AnyObject) {
        self.addWatch()
        self.newSelection(nil)
    }
    
    func addWatch() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let entityDescription=NSEntityDescription.entity(forEntityName: "Watch", in: self.managedObjectContext)
        
        let newWatch = Watch(entity: entityDescription!, insertInto: managedObjectContext)
        let now = Date()
        newWatch.elapsedtime = "00:00:00.0"
        newWatch.splits = ""
        newWatch.starttime = now
        newWatch.name = "Stopwatch"
        newWatch.setState(off: "off")
        let uid = UUID().uuidString //create unique user identifier
        newWatch.setValue(uid, forKey:"uid")
        self.watchArrayController.addObject(newWatch)
        self.saveAndReload()
    }
    
    @IBAction func deleteWatch(_ sender: AnyObject) {
        if watchArrayController.canRemove==true{
            let selectedwatch: Watch=self.watchArrayController.selectedObjects[0] as! Watch
            selectedwatch.watchstate="off"
            let selected_row=self.timetable.selectedRow
            self.watchArrayController.remove(atArrangedObjectIndex: selected_row)
            //dispatch UI task on the main queue
            DispatchQueue.main.async {
                self.splittimes.string=""
                self.timelabel.stringValue="00:00:00.0"
            }
            self.timetable.reloadData()//confirm there are actually more alarms to view
            self.newSelection(sender)
        }
    }
    
    @IBAction func startWatch(_ sender: AnyObject) {
        // This means the person wants to add and start without clicking "add"
        if watchArrayController.selectedObjects.count == 0 {
            self.addWatch()
            self.newSelection(nil)
        }
        if watchArrayController.canRemove==true{
            let selectedwatch: [Watch]=self.watchArrayController.selectedObjects as! [Watch]
            let watch_obj: Watch = self.getWatchObject(selectedwatch)!
            let now = Date()
            if watch_obj.watchstate as NSString == "off" || watch_obj.watchstate == "paused"{
                if watch_obj.watchstate=="paused"{
                    let timeinterval: TimeInterval=Date().timeIntervalSince(watch_obj.pausetime as Date)
                    watch_obj.starttime=watch_obj.starttime.addingTimeInterval(timeinterval)
                }
                else{
                    watch_obj.setValue(now, forKey: "starttime")
                }
                watch_obj.setState(off: "on")
                resetwatch.isHidden=false
                startwatch.isHidden=true
                splitbutton.isHidden=false
                lapbutton.isHidden=false
                pausewatch.isHidden=false
                self.saveAndReload()
                Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(StopWatchViewController.calculateDisplayTime(_:)), userInfo: watch_obj, repeats: true)
                
            }
        }
    }
    
    @IBAction func resetWatch(_ sender: AnyObject) {
        if watchArrayController.canRemove==true{
            let selectedwatch: [Watch]=self.watchArrayController.selectedObjects as! [Watch]
            let watch_obj: Watch = self.getWatchObject(selectedwatch)!
            if watch_obj.watchstate == "on" || watch_obj.watchstate == "paused" {
                watch_obj.setState(off: "off")
                resetwatch.isHidden=true
                startwatch.isHidden=false
                splitbutton.isHidden=true
                lapbutton.isHidden=true
                pausewatch.isHidden=true
                
            }
            watch_obj.elapsedtime="00:00:00.0"
            watch_obj.splits=""
            DispatchQueue.main.async {
                self.splittimes.string=watch_obj.splits
                self.timelabel.stringValue=watch_obj.elapsedtime
            }
            do {
                try self.managedObjectContext.save()
            } catch _ {
            }
            self.timetable.reloadData()
        }
    }
    
    @IBAction func pauseWatch(_ sender: AnyObject) {
        if watchArrayController.canRemove==true{
            let selectedwatch: [Watch]=self.watchArrayController.selectedObjects as! [Watch]
            let watch_obj: Watch = self.getWatchObject(selectedwatch)!
            watch_obj.pausetime=Date()
            if watch_obj.watchstate == "on" {
                watch_obj.setState(off: "paused")
                resetwatch.isHidden=false
                startwatch.isHidden=false
                pausewatch.isHidden=true
                splitbutton.isHidden=true
                lapbutton.isHidden=true
                
            }
            self.saveAndReload()
            DispatchQueue.main.async {
                self.timelabel.stringValue=watch_obj.elapsedtime
            }
        }
    }
    
    
    @objc func calculateDisplayTime(_ timer: Timer) {
        let watch_obj = timer.userInfo as! Watch
        if watch_obj.watchstate=="off" || watch_obj.watchstate=="paused"{
            timer.invalidate()
            return
        }
        let currentselection: [Watch] = self.watchArrayController.selectedObjects as! [Watch]
        let currentuid: NSString = currentselection[0].value(forKey: "uid") as! NSString 
        let identifier = watch_obj.uid
        let starttime=watch_obj.starttime
        let timeinterval=starttime.timeIntervalSinceNow*(-1)
        let displaytime=self.getTimeFormatted(timeinterval)
        watch_obj.elapsedtime="\(displaytime.strHours):\(displaytime.strMinutes):\(displaytime.strSeconds)"
        if currentuid as String == identifier && watch_obj.watchstate=="on"{
            DispatchQueue.main.async {
                self.timelabel.stringValue=watch_obj.elapsedtime
            }
        }
    }
    
    func getTimeFormatted(_ timeinterval: TimeInterval) -> (strHours: String, strMinutes: String, strSeconds: String){
        var hours=UInt16(0)
        var minutes=UInt16(0)
        var seconds=Double(0)
        var timeinterval: TimeInterval=timeinterval
        hours=UInt16((timeinterval/60)/60)
        timeinterval-=TimeInterval(hours)*60*60
        minutes=UInt16(timeinterval/60)
        timeinterval-=TimeInterval(minutes)*60
        seconds=Double(timeinterval)
        let strHours=hours > 9 ? String(hours):"0"+String(hours)
        let strMinutes=minutes > 9 ? String(minutes):"0"+String(minutes)
        let strSeconds=seconds > 9.99 ? String(format:"%.1f", seconds):"0"+String(format:"%.1f", seconds)
        return (strHours, strMinutes, strSeconds)
    }
    
    @IBAction func updateSplitTime(_ sender: AnyObject) {
        let selectedwatch: [Watch]=self.watchArrayController.selectedObjects as! [Watch]
        let watch_obj: Watch = self.getWatchObject(selectedwatch)!
        watch_obj.splits=String(watch_obj.splits+"Split Time:"+watch_obj.elapsedtime+"\n")
        DispatchQueue.main.async {
            self.splittimes.string=watch_obj.splits
        }
        do {
            try self.managedObjectContext.save()
        } catch _ {
        }
        self.timetable.reloadData()
    }
    
    @IBAction func updateLapTime(_ sender: AnyObject) {
        let selectedwatch: [Watch]=self.watchArrayController.selectedObjects as! [Watch]
        let watch_obj: Watch = self.getWatchObject(selectedwatch)!
        watch_obj.splits=String(watch_obj.splits+"Lap Time:"+self.timelabel.stringValue+"\n")
        DispatchQueue.main.async {
            self.splittimes.string=watch_obj.splits
        }
        watch_obj.elapsedtime="00:00:00.0"
        let now: Date = Date()
        watch_obj.starttime=now
        self.saveAndReload()
    }
    
    
    @IBAction func newSelection(_ sender: AnyObject?) {
        if watchArrayController.canRemove==true{ //confirm there are actually more watches to view
            let watch_obj: Watch=self.watchArrayController.selectedObjects[0] as! Watch
            let watchstate: NSString = watch_obj.watchstate as NSString
            if watchstate == "on" {
                resetwatch.isHidden=false
                startwatch.isHidden=true
                pausewatch.isHidden=false
                lapbutton.isHidden=false
                splitbutton.isHidden=false
            }
            if watchstate == "off" || watchstate == "paused"{
                resetwatch.isHidden=true
                startwatch.isHidden=false
                pausewatch.isHidden=true
                lapbutton.isHidden=true
                splitbutton.isHidden=true
            }
            DispatchQueue.main.async {
                self.splittimes.string=watch_obj.splits
                self.timelabel.stringValue=watch_obj.elapsedtime
            }
        } else {
            resetwatch.isHidden=true
            startwatch.isHidden=false
            pausewatch.isHidden=true
            lapbutton.isHidden=true
            splitbutton.isHidden=true
            
            DispatchQueue.main.async {
                self.splittimes.string=""
                self.timelabel.stringValue=""
            }
        }
    }
    
    func getWatchObject(_ selectedwatch: [Watch]) -> Watch?{
        let identifier: NSString = selectedwatch[0].value(forKey: "uid") as! NSString
        var results = [NSManagedObject]()
        let watchrequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Watch")
        var watch_obj: Watch
        do{
            watchrequest.returnsDistinctResults = true
            watchrequest.returnsObjectsAsFaults = false
            watchrequest.predicate = NSPredicate(format: "uid=%@", identifier)
            results = try managedObjectContext.fetch(watchrequest) as! [NSManagedObject]
        }
        catch {
            print("Unable to load existing stopwatch.")
        }
        if results.count == 1{
            watch_obj = results[0] as! Watch
            return watch_obj
        }
        else{
            return nil
        }
    }
    
    func saveAndReload(){
        do {
            try self.managedObjectContext.save()
        } catch _ {
        }
        self.timetable.reloadData()
    }
    
}

