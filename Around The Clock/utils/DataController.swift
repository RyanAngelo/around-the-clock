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

    private var managers: [UUID: any AtcManager] = [:]
    
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
            let manager: AlarmManager = AlarmManager(dc: self, updateInterval: 1, alarmObject: alarm)
            addManager(am: manager)
        }
        for timer in self.timerItems {
            let manager: TimerManager = TimerManager(dc: self, updateInterval: 0.1, timerObject: timer)
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
            let manager: AlarmManager = AlarmManager(dc: self, updateInterval: 1, alarmObject: newItem)
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
            let manager: TimerManager = TimerManager(dc: self, updateInterval: 1, timerObject: newItem)
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
    
    public func updateTimerManager(id: UUID) {
        saveContext()
        let tm: TimerManager = getManager(uniqueIdentifier: id) as! TimerManager;
        tm.reset()
        tm.updateData()
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
        return managers[uniqueIdentifier]!
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
            let am: AlarmManager = AlarmManager(dc: result, updateInterval: 1, alarmObject: newAlarm)
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
        return result
    }()
    
}

extension Binding {
     func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T>  {
         Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
    }
}

