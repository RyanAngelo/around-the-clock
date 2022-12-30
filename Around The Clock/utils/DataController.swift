//
//  ObservableManager.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/22/22.
//

import Foundation
import CoreData
import SwiftUI

/**
 DataController manages all data interactions with CoreData and the management observables
 */
class DataController: ObservableObject {
        
    //Use "Around_The_Clock data model, prepare it
    let container = NSPersistentContainer(name: "Around_The_Clock")
    
    private let alarmController: NSFetchedResultsController<AtcAlarm>
    private let timerController: NSFetchedResultsController<AtcTimer>
    private let stopwatchController: NSFetchedResultsController<AtcStopwatch>

    private var managers: [UUID: any AtcManager] = [:]
    
    @Published var alarmItems: [AtcAlarm] = []
    @Published var timerItems: [AtcTimer] = []
    @Published var stopwatchItems: [AtcStopwatch] = []
    
    @Published var activeAlert1: ActiveAlert?
    @Published var alert1Present: Bool = false
    @Published var activeAlert2: ActiveAlert?
    @Published var alert2Present: Bool = false
    var queuedAlerts: [ActiveAlert] = []
    
    //Default update intervals, in seconds
    private let timerUpdateInterval: TimeInterval = 0.1
    private let stopwatchUpdateInterval: TimeInterval = 0.101
    private let alarmUpdateInterval: TimeInterval = 1
    
    init(inMemory: Bool = false) {
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unresolved error \(error), \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        let alarmFetchRequest: NSFetchRequest<AtcAlarm>
        alarmFetchRequest = AtcAlarm.fetchRequest()
        alarmFetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \AtcAlarm.name, ascending: true)
        ]
        alarmController = NSFetchedResultsController(
            fetchRequest: alarmFetchRequest,
            managedObjectContext: container.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        let timerFetchRequest: NSFetchRequest<AtcTimer>
        timerFetchRequest = AtcTimer.fetchRequest()
        timerFetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \AtcTimer.name, ascending: true)
        ]
        timerController = NSFetchedResultsController(
            fetchRequest: timerFetchRequest,
            managedObjectContext: container.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        let stopwatchFetchRequest: NSFetchRequest<AtcStopwatch>
        stopwatchFetchRequest = AtcStopwatch.fetchRequest()
        stopwatchFetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \AtcStopwatch.name, ascending: true)
        ]
        stopwatchController = NSFetchedResultsController(
            fetchRequest: stopwatchFetchRequest,
            managedObjectContext: container.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        fetchTimers()
        fetchAlarms()
        fetchStopwatches()
        createClocks()
    }
    
    /**
     Create clocks that are associated with the lists that have been generated
     from the content of CoreData.
     The clocks manage the logic behind the persisted objects (e.g. counting).
     */
    private func createClocks() {
        //Create alarm manager associated with object
        for alarm in self.alarmItems {
            let manager: AlarmManager = AlarmManager(dc: self, updateInterval: alarmUpdateInterval, alarmObject: alarm)
            if (alarm.stopTime!.timeIntervalSinceNow < 0) {
                //Set alarm time to one hour ahead if time is in the past
                alarm.stopTime = Date().advanced(by: 60*60)
            }
            addManager(am: manager)
        }
        for timer in self.timerItems {
            let manager: TimerManager = TimerManager(dc: self, updateInterval: timerUpdateInterval, timerObject: timer)
            addManager(am: manager)
        }
        for stopwatch in self.stopwatchItems {
            let manager: StopwatchManager = StopwatchManager(dc: self, updateInterval: stopwatchUpdateInterval, stopwatchObject: stopwatch)
            addManager(am: manager)
        }
    }
    
    public func addAlarm() {
        withAnimation {
            let newItem = AtcAlarm(context: container.viewContext)
            newItem.uniqueId = UUID()
            //Default time is now + 60 minutes
            newItem.stopTime = Date.now.advanced(by: 60 * 60)
            newItem.name = "New Alarm"
            newItem.state = ClockState.STOPPED.rawValue
            let manager: AlarmManager = AlarmManager(dc: self, updateInterval: alarmUpdateInterval, alarmObject: newItem)
            addManager(am: manager)
            saveContext()
            fetchAlarms()
        }
    }
    
    private func fetchAlarms() {
        try? alarmController.performFetch()
        alarmItems = alarmController.fetchedObjects ?? []
    }
    
    public func fetchAlarm(id: UUID) -> AtcAlarm? {
        if let alarmItem = alarmItems.first(where: {$0.uniqueId == id}) {
            return alarmItem
        }
        return nil
    }
    
    public func deleteManagedObject(atcObject: AtcObject) {
        removeManager(uniqueIdToRemove: atcObject.uniqueId!)
        container.viewContext.delete(atcObject)
        saveContext()
        fetchAlarms()
        fetchTimers()
        fetchStopwatches()
    }
    
    public func setManagerState(atcObject: AtcObject, newState: ClockState) {
        atcObject.state = newState.rawValue
        if let co: any AtcManager = managers[atcObject.uniqueId!] {
            if (newState == ClockState.ACTIVE) {
                co.start()
            } else if (newState == ClockState.STOPPED || newState == ClockState.PAUSED) {
                co.stop()
            }
            atcObject.state = newState.rawValue
        } else {
            print("Error! No Manager for associated ATC Object")
        }
        saveContext()
        //TODO: Manage this in a less intensive manner
        fetchTimers()
        fetchAlarms()
        fetchStopwatches()
    }
    
    public func resetManager(atcObject: AtcObject) {
        if let co: any AtcManager = managers[atcObject.uniqueId!] {
            co.reset()
        }
    }
    
    public func addTimer() {
        withAnimation {
            let newItem = AtcTimer(context: container.viewContext)
            newItem.uniqueId = UUID()
            newItem.stopTime = 0
            newItem.name = "New Timer"
            newItem.state = ClockState.STOPPED.rawValue
            let manager: TimerManager = TimerManager(dc: self, updateInterval: timerUpdateInterval, timerObject: newItem)
            addManager(am: manager)
            saveContext()
            fetchTimers()
        }
    }
    
    private func fetchTimers() {
        try? timerController.performFetch()
        timerItems = timerController.fetchedObjects ?? []
    }
    
    public func fetchTimer(id: UUID) -> AtcTimer? {
        if let timerItem = timerItems.first(where: {$0.uniqueId == id}) {
            return timerItem
        }
        return nil
    }
    
    public func addStopwatch() {
        withAnimation {
            let newItem = AtcStopwatch(context: container.viewContext)
            newItem.uniqueId = UUID()
            newItem.name = "New Stopwatch"
            newItem.state = ClockState.STOPPED.rawValue
            let manager: StopwatchManager = StopwatchManager(dc: self, updateInterval: stopwatchUpdateInterval, stopwatchObject: newItem)
            addManager(am: manager)
            saveContext()
            fetchStopwatches()
        }
    }
    
    private func fetchStopwatches() {
        try? stopwatchController.performFetch()
        self.stopwatchItems = stopwatchController.fetchedObjects ?? []
    }
    
    public func fetchStopwatch(id: UUID) -> AtcStopwatch? {
        if let stopwatchItem = stopwatchItems.first(where: {$0.uniqueId == id}) {
            return stopwatchItem
        }
        return nil
    }
    
    public func addLap(stopwatch: AtcStopwatch, newLapTime: TimeInterval) {
        let newLap = AtcLap(context: container.viewContext)
        newLap.uniqueId = UUID()
        newLap.name = (stopwatch.name ?? "Unknown Stopwatch") + " Lap"
        newLap.stopwatch = stopwatch
        newLap.fastest = false //TODO: Determine if fastest lap
        newLap.timeInterval = newLapTime
        saveContext()
    }
    
    public func saveContext() {
        do {
            try container.viewContext.save()
        } catch { //TODO: Add better error handling
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    public func saveAndUpdateAlarms() {
        saveContext()
        fetchAlarms()
    }
    
    public func saveAndUpdateTimers() {
        saveContext()
        fetchTimers()
    }
    
    public func saveAndUpdateStopwatches() {
        saveContext()
        fetchStopwatches()
    }
    
    public func addManager(am: any AtcManager) {
        managers.updateValue(am, forKey: am.getManagedObjectUniqueId())
    }
    
    public func removeManager(uniqueIdToRemove: UUID) {
        if let manager = managers[uniqueIdToRemove] {
            // now val is not nil and the Optional has been unwrapped, so use it
            manager.stop()
            managers.removeValue(forKey: uniqueIdToRemove)
        }
        managers.removeValue(forKey: uniqueIdToRemove)
    }
    
    //TODO: Create a management object if one does not exist wrather than force unwrap.
    //This could be accomplished by passing the managed object rather than the UUID
    public func getManager(uniqueIdentifier: UUID) -> any AtcManager {
        let manager: any AtcManager = managers[uniqueIdentifier]!
        return manager
    }
    
    //Start Alert handling section
    
    public func addAlert(atcObject: AtcObject) {
        let newAlert = ActiveAlert(associatedObject: atcObject)
        if (activeAlert1 == nil) {
            activeAlert1 = newAlert
            alert1Present = true
        } else if (activeAlert2 == nil) {
            activeAlert2 = newAlert
            alert2Present = true
        }
        else {
            queuedAlerts.append(newAlert)
        }
    }
    
    /**
     Having endAlert1 and endAlert2 allows us to queue up alerts.
     When one finishes, it can check the other "register" to see if it is free (it always should be)
     In this way, we can always be cycling through alerts that are queued up.
     The fundamental issue with the alerts is that they only set alertXPresent to false when they finish the
     call that they are assigned in their button action.
     See ParentClockView .alert
     */
    public func endAlert1(activeAlert: ActiveAlert) {
        let manager: any AtcManager = getManager(uniqueIdentifier: activeAlert.associatedObject.uniqueId!)
        manager.endActivation()
        activeAlert1 = nil
        if (activeAlert2 == nil) {
            if (!queuedAlerts.isEmpty) {
                activeAlert2 = queuedAlerts.removeFirst()
                alert2Present = true
            }
        }
    }
    
    public func endAlert2(activeAlert: ActiveAlert) {
        let manager: any AtcManager = getManager(uniqueIdentifier: activeAlert.associatedObject.uniqueId!)
        manager.endActivation()
        activeAlert2 = nil
        if (activeAlert1 == nil) {
            if (!queuedAlerts.isEmpty) {
                activeAlert1 = queuedAlerts.removeFirst()
                alert1Present = true
            }
        }
    }
    
    //End Alert Section
    
    //For preview generation
    static var preview: DataController = {
        let result = DataController(inMemory: true)
        let viewContext = result.container.viewContext
        
        for _ in 0..<2 {
            var newAlarm = AtcAlarm(context: viewContext)
            newAlarm.stopTime = Date()
            newAlarm.name = "Active Alarm"
            newAlarm.uniqueId = UUID()
            newAlarm.state = ClockState.ACTIVE.rawValue
            let am: AlarmManager = AlarmManager(dc: result, updateInterval: 1, alarmObject: newAlarm)
            am.stop()
            result.addManager(am: am)
            var newTimer = AtcTimer(context: viewContext)
            newTimer.stopTime = 10000
            newTimer.name = "Active Timer"
            newTimer.uniqueId = UUID()
            newTimer.state = ClockState.ACTIVE.rawValue
            let tm: TimerManager = TimerManager(dc: result, updateInterval: 1, timerObject: newTimer)
            result.addManager(am: tm)
            
        }
        for _ in 0..<2 {
            var newTimer = AtcTimer(context: viewContext)
            newTimer.stopTime = 10
            newTimer.name = "New Timer"
            newTimer.uniqueId = UUID()
            newTimer.state = ClockState.PAUSED.rawValue
            let manager: TimerManager = TimerManager(dc: result, updateInterval: 1, timerObject: newTimer)
            manager.stop()
            result.addManager(am: manager)
        }
        for _ in 0..<2 {
            var newStopwatch = AtcStopwatch(context: viewContext)
            newStopwatch.startTime = Date.now
            newStopwatch.name = "New Stopwatch"
            newStopwatch.uniqueId = UUID()
            newStopwatch.state = ClockState.PAUSED.rawValue
            var newLap: AtcLap = AtcLap(context: viewContext)
            newLap.stopwatch = newStopwatch
            newLap.timeInterval = 100
            newLap.name = "Test Lap"
            newLap.uniqueId = UUID()
            let manager: StopwatchManager = StopwatchManager(dc: result, updateInterval: 1, stopwatchObject: newStopwatch)
            manager.stop()
            result.addManager(am: manager)
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        result.fetchAlarms()
        result.fetchTimers()
        result.fetchStopwatches()
        return result
    }()
    
}

extension Binding {
     func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T>  {
         Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
    }
}

