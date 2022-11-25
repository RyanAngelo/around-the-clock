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
    
    private var managementDictionary: [ObjectIdentifier: ClockObjectProtocol] = [:]
    
    private let alarmController: NSFetchedResultsController<AtcAlarm>
    private let timerController: NSFetchedResultsController<AtcTimer>
    
    @Published var alarmItems: [AtcAlarm] = []
    @Published var timerItems: [AtcTimer] = []
    
    //var alarmDictionary: [ObjectIdentifier: AtcAlarm] = [:]
    
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

    }
    
    public func addAlarm() {
        withAnimation {
            let newItem = AtcAlarm(context: container.viewContext)
            newItem.uniqueId = UUID()
            newItem.stop_time = Date()
            newItem.name = "New Alarm"
            newItem.state = ClockState.PAUSED.rawValue
            let alarmClock: ClockAlarm = ClockAlarm(updateInterval: 1, alarmObject: newItem)
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
    
    public func addManagementObject(observableObject: ClockAlarm) {
        managementDictionary.updateValue(observableObject, forKey: observableObject.getManagedIdentifier())
    }
    
    public func removeManagementObject(objIdToRemove: ObjectIdentifier) {
        self.managementDictionary.removeValue(forKey: objIdToRemove)
    }
    
    //For preview generation
    static var preview: DataController = {
        let result = DataController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<5 {
            let newAlarm = AtcAlarm(context: viewContext)
            newAlarm.stop_time = Date()
            newAlarm.name = "New Alarm"
            newAlarm.uniqueId = UUID()
            newAlarm.state = ClockState.PAUSED.rawValue
            let newTimer = AtcTimer(context: viewContext)
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

