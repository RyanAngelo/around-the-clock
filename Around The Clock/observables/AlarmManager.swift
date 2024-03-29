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
    let ac: AudioController = AudioController()
    let defaultDisplay: String = "00:00:00"

    @ObservedObject var dc: DataController
    
    @Published var clockStatus: ClockStatus
    @Published var managedObject: AtcAlarm
    
    init(dc: DataController, updateInterval: TimeInterval, alarmObject: AtcAlarm) {
        self.dc = dc
        self.updateInterval = updateInterval
        self.managedObject = alarmObject
        self.clockStatus = ClockStatus(displayValue:defaultDisplay, activated: true, associatedObject: alarmObject.uniqueId!)
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
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
        if (self.managedObject.state == ClockState.ACTIVE.rawValue) {
            let timeRemainingInterval: TimeInterval = (managedObject.stopTime?.timeIntervalSinceNow)!
            clockStatus.displayValue = formatter.string(from: timeRemainingInterval) ?? defaultDisplay
            if (timeRemainingInterval <= 0) {
                triggerActivation()
                clockStatus.displayValue = defaultDisplay
            }
        } else {
            clockStatus.displayValue = defaultDisplay
        }
    }
        
    func dateHasChanged() {
        updateData()
        dc.saveContext()
    }
    
    func audioHasChanged() {
        dc.saveContext()
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
        managedObject.state = newState.rawValue
        dc.saveContext()
        if (newState == ClockState.ACTIVE) {
            start()
        } else if (newState == ClockState.STOPPED || newState == ClockState.PAUSED) {
            stop()
        }
        updateData() //Update data after timer stops
    }
    
    func triggerActivation() {
        clockStatus.activated = true
        if (!self.managedObject.audioFile!.elementsEqual(AudioFiles.None.rawValue)) {
            ac.playSound(soundResource: self.managedObject.audioFile!)
        }
        dc.addAlert(atcObject: managedObject)
        self.stop()
    }
    
    func endActivation() {
        clockStatus.activated = false
        ac.stopSound()
        setManagedObjectState(newState: ClockState.PAUSED)
    }
    
    func reset() {}
    
}
