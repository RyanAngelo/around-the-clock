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
 ObservableManager manages ObservableObjects
 The Observable objects include AlarmClock, StopWatch, etc.
 Multiple instances of each can be present at any given time and the
 ObservableManager keeps track of them. They are acquired by
 knowing the Identifier of the underlying object (e.g. AtcAlarm, AtcStopwatch)
 */
class DataController: ObservableObject {
        
    //Use "Around_The_Clock data model, prepare it
    let container = NSPersistentContainer(name: "Around_The_Clock")
    
    private let alarmController: NSFetchedResultsController<AtcAlarm>
    private let timerController: NSFetchedResultsController<AtcTimer>

    var clockStatus: [UUID: ClockStatus] = [:]
    var alarmManagers: [UUID: AlarmManager] = [:]
    
    @Published var alarmItems: [AtcAlarm] = []
    @Published var timerItems: [AtcTimer] = []
        
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
            NSSortDescriptor(keyPath: \AtcAlarm.state, ascending: true)
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
        
        fetchTimers()
        fetchAlarms()
        createClocks()
    }
    
    /**
     Create clocks that are associated with the lists that have been generated
     from the content of CoreData.
     The clocks manage the logic behind the persisted objects (e.g. counting).
     */
    private func createClocks() {
        //Create alarm clock associated with object
        for alarm in self.alarmItems {
            let manager: AlarmManager = AlarmManager(updateInterval: 1, alarmObject: alarm)
            addAlarmManager(am: manager)
        }
    }
    
    public func addAlarm() {
        withAnimation {
            let newItem = AtcAlarm(context: container.viewContext)
            newItem.uniqueId = UUID()
            //Default time is now + 60 minutes
            newItem.stopTime = Date.now.advanced(by: 60 * 60)
            newItem.name = "New Alarm"
            newItem.state = ClockState.PAUSED.rawValue
            let manager: AlarmManager = AlarmManager(updateInterval: 1, alarmObject: newItem)
            addAlarmManager(am: manager)
            self.saveContext()
            self.fetchAlarms()
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
    
    public func deleteAlarm(offsets: IndexSet) {
        withAnimation {
            offsets.map { alarmItems[$0] }.forEach(container.viewContext.delete)
            self.saveContext()
            self.fetchAlarms()
        }
    }
    
    public func setAlarmState(atcObject: AtcObject, newState: ClockState) {
        atcObject.state = newState.rawValue
        if let co: AlarmManager = alarmManagers[atcObject.uniqueId!] {
            if (newState == ClockState.ACTIVE) {
                co.start()
            } else if (newState == ClockState.STOPPED || newState == ClockState.PAUSED) {
                co.stop()
            }
        } else {
            print("Error! No ClockObjectProtocol for associated ATC Object")
        }
        saveContext()
        //TODO: Manage this in a less intensive manner
        fetchTimers()
        fetchAlarms()
    }
    
    public func addTimer() {
        withAnimation {
            let newItem = AtcTimer(context: container.viewContext)
            newItem.uniqueId = UUID()
            newItem.timeRemaining = 0
            newItem.name = "New Timer"
            newItem.state = ClockState.PAUSED.rawValue
            self.saveContext()
            self.fetchTimers()
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
    
    public func deleteTimer(offsets: IndexSet) {
        withAnimation {
            offsets.map { timerItems[$0] }.forEach(container.viewContext.delete)
            self.saveContext()
        }
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
    
    public func addAlarmManager(am: AlarmManager) {
        alarmManagers.updateValue(am, forKey: am.getManagedObjectUniqueId())
        clockStatus.updateValue(am.getStatus(), forKey: am.getManagedObjectUniqueId())
    }
    
    public func removeAlarmManager(uniqueIdToRemove: UUID) {
        self.alarmManagers.removeValue(forKey: uniqueIdToRemove)
        self.clockStatus.removeValue(forKey: uniqueIdToRemove)
    }
    
    //TODO: Create a management object if one does not exist wrather than force unwrap.
    public func getAlarmManager(uniqueIdentifier: UUID) -> AlarmManager {
        return self.alarmManagers[uniqueIdentifier]!
    }
    
    public func getClockStatus(uniqueIdentifier: UUID) -> ClockStatus {
        return self.clockStatus[uniqueIdentifier]!
    }
    
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
            let manager: AlarmManager = AlarmManager(updateInterval: 1, alarmObject: newAlarm)
            result.addAlarmManager(am: manager)
            var newTimer = AtcTimer(context: viewContext)
            newTimer.timeRemaining = 100
            newTimer.name = "Active Timer"
            newTimer.uniqueId = UUID()
            newTimer.state = ClockState.ACTIVE.rawValue
            
        }
        for _ in 0..<2 {
            var newAlarm = AtcAlarm(context: viewContext)
            newAlarm.stopTime = Date()
            newAlarm.name = "New Alarm"
            newAlarm.uniqueId = UUID()
            newAlarm.state = ClockState.PAUSED.rawValue
            let manager: AlarmManager = AlarmManager(updateInterval: 1, alarmObject: newAlarm)
            result.addAlarmManager(am: manager)
            var newTimer = AtcTimer(context: viewContext)
            newTimer.timeRemaining = 100
            newTimer.name = "New Timer"
            newTimer.uniqueId = UUID()
            newTimer.state = ClockState.PAUSED.rawValue
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        result.fetchAlarms()
        result.fetchTimers()
        return result
    }()
    
}

extension Binding {
     func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T>  {
         Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
    }
}

