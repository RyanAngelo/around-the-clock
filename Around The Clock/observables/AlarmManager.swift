//
//  AlarmManager.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/22/22.
//

import Foundation
import SwiftUI

/**
 AlarmManager manages a single alarm
 The AlarmManager calculates the time remaining
 The AlarmManager is tied to an alarmObject
 */
class AlarmManager: ObservableObject, AtcManager{
    
            
    private var timer = Timer()
    private var updateInterval: TimeInterval
    let formatter = DateComponentsFormatter()
    
    @ObservedObject var dc: DataController
    
    @Published var clockStatus: ClockStatus
    @Published var managedObject: AtcAlarm
    @Published var currentState: ClockState
    
    init(dc: DataController, updateInterval: TimeInterval, alarmObject: AtcAlarm) {
        self.dc = dc
        self.updateInterval = updateInterval
        self.managedObject = alarmObject
        self.clockStatus = ClockStatus(displayValue:"00:00:00", activated: true, associatedObject: alarmObject.uniqueId!)
        self.currentState = ClockState(rawValue: alarmObject.state) ?? ClockState.STOPPED
        if (self.managedObject.state == ClockState.ACTIVE.rawValue) {
            self.start()
        } else {
            self.stop()
        }
    }
    
    //TODO: Make sure that this runs when window minimized
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
            self.updateData()
        }
    }
    
    func stop() {
        timer.invalidate()
    }
    
    func updateData() {
        let timeRemainingInterval: TimeInterval = (managedObject.stopTime?.timeIntervalSince(Date.now))!
        clockStatus.displayValue = formatter.string(from: timeRemainingInterval) ?? "00:00:00"
    }
    
    func updateDate(newDate: Date) {
        managedObject.stopTime = newDate
        updateData()
    }
    
    func getManagedObjectUniqueId() -> UUID {
        return self.managedObject.uniqueId!
    }
    
    func getStatus() -> ClockStatus {
        return self.clockStatus
    }
    
    func getManagedObject() -> AtcObject {
        return managedObject
    }
    
    func setManagedObjectState(newState: ClockState) {
        if (newState == ClockState.ACTIVE) {
            start()
        } else if (newState == ClockState.STOPPED || newState == ClockState.PAUSED) {
            stop()
        }
        currentState = newState
        managedObject.state = newState.rawValue
        dc.saveContext()
    }
    
    func reset() {}
    
}
