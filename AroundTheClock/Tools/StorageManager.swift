//
//  StorageManager.swift
//  AroundTheClock
//
//  Created by Ryan Angelo on 12/30/18.
//  Copyright © 2018 Ryan Angelo. All rights reserved.
//
import CoreData
import Cocoa

class StorageManager {
    
    let persistentContainer: NSPersistentContainer!
    
    //MARK: Init with dependency
    init(container: NSPersistentContainer) {
        self.persistentContainer = container
        self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    convenience init() {
        //Use the default container for production environment
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate unavailable")
        }
        self.init(container: appDelegate.persistentContainer)
    }
    
    lazy var backgroundContext: NSManagedObjectContext = {
        return self.persistentContainer.newBackgroundContext()
    }()
    
    //MARK: CRUD
    /****** ALARMS ******/
    @discardableResult func addAlarm( time: Date, name: String, state: String ) -> Alarm? {
        guard let alarm = NSEntityDescription.insertNewObject(forEntityName: "Alarm", into: backgroundContext) as? Alarm else { return nil }
        
        alarm.alarmtime = time
        alarm.name = name
        alarm.alarmstate = state
        
        let uid = UUID().uuidString //create unique user identifier
        alarm.uid = uid
        
        return alarm
    }
    
    func fetchAllAlarms(sorted: Bool = true) -> [Alarm] {
        let request: NSFetchRequest<Alarm> = Alarm.fetchRequest() as! NSFetchRequest<Alarm>
        
        if sorted {
            let alarmSort = NSSortDescriptor(key: #keyPath(Alarm.name), ascending: true)
            request.sortDescriptors = [alarmSort]
        }
        
        let results = try? persistentContainer.viewContext.fetch(request)
        return results ?? [Alarm]()
    }
    
    func fetchAllActiveAlarms() -> [Alarm] {
        let request: NSFetchRequest<NSFetchRequestResult> = Alarm.fetchRequest()
        
        request.predicate = NSPredicate(format: "alarmstate='activated'")
        
        let results = try? persistentContainer.viewContext.fetch(request)
        return results as! [Alarm]
    }
    
    func fetchAlarm(uid: String) -> [Alarm] {
        let request: NSFetchRequest<Alarm> = Alarm.fetchRequest() as! NSFetchRequest<Alarm>
        
        request.predicate = NSPredicate(format: "uid == %@", uid)
        
        let alarmSort = NSSortDescriptor(key: #keyPath(Alarm.name), ascending: true)
        request.sortDescriptors = [alarmSort]
        
        let results = try? persistentContainer.viewContext.fetch(request)
        return results ?? [Alarm]()
    }
    
    /****** WATCHES ******/
    @discardableResult func addWatch( elapsedtime: String, name: String, state: String ) -> Watch? {
        guard let watch = NSEntityDescription.insertNewObject(forEntityName: "Watch", into: backgroundContext) as? Watch else { return nil }
        let now = Date()
        watch.elapsedtime = elapsedtime
        watch.name = name
        watch.watchstate = state
        watch.starttime = now
        let uid = UUID().uuidString //create unique user identifier
        watch.uid = uid
        return watch
    }
    
    func fetchAllWatches(sorted: Bool = true) -> [Watch] {
        let request: NSFetchRequest<Watch> = Watch.fetchRequest() as! NSFetchRequest<Watch>
        
        if sorted {
            let watchSort = NSSortDescriptor(key: #keyPath(Watch.name), ascending: true)
            request.sortDescriptors = [watchSort]
        }
        
        let results = try? persistentContainer.viewContext.fetch(request)
        return results ?? [Watch]()
    }
    
    func fetchAllActiveWatches() -> [Watch] {
        let request: NSFetchRequest<NSFetchRequestResult> = Watch.fetchRequest()
        
        request.predicate = NSPredicate(format: "watchstate='activated'")
        
        let results = try? persistentContainer.viewContext.fetch(request)
        return results as! [Watch]
    }
    
    func fetchWatch(uid: String) -> [Watch] {
        let request: NSFetchRequest<Watch> = Watch.fetchRequest() as! NSFetchRequest<Watch>
        
        request.predicate = NSPredicate(format: "uid == %@", uid)
        
        let watchSort = NSSortDescriptor(key: #keyPath(Watch.name), ascending: true)
        request.sortDescriptors = [watchSort]
        
        let results = try? persistentContainer.viewContext.fetch(request)
        return results ?? [Watch]()
    }
    
    /****** COUNTDOWNS ******/
    @discardableResult func addCountdown( startcountdowntime: Int, name: String, state: String ) -> Countdown? {
        guard let countdown = NSEntityDescription.insertNewObject(forEntityName: "Countdown", into: backgroundContext) as? Countdown else { return nil }
        countdown.startcountdowntime = startcountdowntime
        countdown.countdowntime = startcountdowntime
        countdown.name = name
        countdown.setState(state: state)
        let uid = UUID().uuidString //create unique user identifier
        countdown.uid = uid
        return countdown
    }
    
    func fetchAllCountdowns(sorted: Bool = true) -> [Countdown] {
        let request: NSFetchRequest<Countdown> = Countdown.fetchRequest() as! NSFetchRequest<Countdown>
        
        if sorted {
            let countdownSort = NSSortDescriptor(key: #keyPath(Countdown.name), ascending: true)
            request.sortDescriptors = [countdownSort]
        }
        
        let results = try? persistentContainer.viewContext.fetch(request)
        return results ?? [Countdown]()
    }
    
    func fetchAllActiveCountdowns() -> [Countdown] {
        let request: NSFetchRequest<NSFetchRequestResult> = Countdown.fetchRequest()
        
        request.predicate = NSPredicate(format: "countdownstate='activated'")
        
        let results = try? persistentContainer.viewContext.fetch(request)
        return results as! [Countdown]
    }
    
    func fetchCountdown(uid: String) -> [Countdown] {
        let request: NSFetchRequest<Countdown> = Countdown.fetchRequest() as! NSFetchRequest<Countdown>
        
        request.predicate = NSPredicate(format: "uid == %@", uid)
        
        let countdownSort = NSSortDescriptor(key: #keyPath(Countdown.name), ascending: true)
        request.sortDescriptors = [countdownSort]
        
        let results = try? persistentContainer.viewContext.fetch(request)
        return results ?? [Countdown]()
    }
    //MARK: END CRUD
    
    func remove( objectID: NSManagedObjectID ) {
        let obj = backgroundContext.object(with: objectID)
        backgroundContext.delete(obj)
    }
    
    func save() {
        if backgroundContext.hasChanges {
            do {
                try backgroundContext.save()
            } catch {
                print("Save error \(error)")
            }
        }
        
    }
}
