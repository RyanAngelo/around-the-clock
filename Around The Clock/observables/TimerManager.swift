//
//  TimerManager.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/23/22.
//

import Foundation
import SwiftUI

class TimerManager: ObservableObject, AtcManager {    
    
    private var timer = Timer()
    let formatter = DateComponentsFormatter()

    private var updateInterval: TimeInterval //Seconds
    private var timeElapsed: TimeInterval = 0

    @ObservedObject var dc: DataController
    
    @Published var clockStatus: ClockStatus
    //Hours, minutes and seconds to countdown
    @Published var hours: Int
    @Published var minutes: Int
    @Published var seconds: Int
    
    //TODO: Should I publish timerObject?
    @Published var managedObject: AtcTimer
        
    init(dc: DataController, updateInterval: TimeInterval, timerObject: AtcTimer) {
        self.dc = dc
        self.updateInterval = updateInterval
        self.managedObject = timerObject
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        self.clockStatus = ClockStatus(displayValue:"00:00:00", activated: false, currentState: ClockState(rawValue: timerObject.state) ?? ClockState.STOPPED, associatedObject: timerObject.uniqueId!)
        self.hours = TimerManager.getHours(countdownTime: timerObject.stopTime)
        self.minutes = TimerManager.getMinutes(countdownTime: timerObject.stopTime)
        self.seconds = TimerManager.getSeconds(countdownTime: timerObject.stopTime)
        self.updateData()
        if (self.managedObject.state == ClockState.ACTIVE.rawValue) {
            self.start()
        } else {
            self.stop()
        }
    }
    
    func start() {
        self.managedObject.lastCheckDate = Date.now
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
            let timeSinceLastCheck = -self.managedObject.lastCheckDate!.timeIntervalSinceNow
            self.timeElapsed = self.timeElapsed.advanced(by: timeSinceLastCheck)
            self.updateData()
            self.managedObject.lastCheckDate = Date.now
        }
    }
    
    func stop() {
        timer.invalidate()
    }
    
    func updateData() {
        let timeRemaining: TimeInterval = ceil(managedObject.stopTime.advanced(by: -timeElapsed))
        if (timeRemaining <= 0) {
            triggerActivation()
        }
        clockStatus.displayValue = formatter.string(from: timeRemaining) ?? "00:00:00"
    }
    
    func triggerActivation() {
        clockStatus.activated = true
        self.stop()
    }
    
    func reset() {
        self.stop()
        self.timeElapsed = 0
        self.updateData()
        self.clockStatus.activated = false
        if (!self.timer.isValid && self.managedObject.state == ClockState.ACTIVE.rawValue) {
            self.start()
        }
    }
    
    func assignHoursMinutesSeconds() {
        hours = TimerManager.getHours(countdownTime: managedObject.stopTime)
        minutes = TimerManager.getMinutes(countdownTime: managedObject.stopTime)
        seconds = TimerManager.getSeconds(countdownTime: managedObject.stopTime)
    }
    
    static func getHours(countdownTime: Double) -> Int {
        return Int(countdownTime / 3600)
    }
    
    static func getMinutes(countdownTime: Double) -> Int {
        return Int((countdownTime.truncatingRemainder(dividingBy: 3600)) / 60)
    }
    
    static func getSeconds(countdownTime: Double) -> Int {
        return Int((countdownTime.truncatingRemainder(dividingBy: 3600)).truncatingRemainder(dividingBy: 60))
    }
    
    func setManagedObjectTime() {
        managedObject.stopTime =
        Double(self.hours * 60 * 60 +
               self.minutes * 60 +
               self.seconds)
        updateData()
        dc.saveContext()
    }
    
    func setManagedObjectState(newState: ClockState) {
        if (newState == ClockState.ACTIVE) {
            start()
        } else if (newState == ClockState.STOPPED || newState == ClockState.PAUSED) {
            stop()
        }
        managedObject.state = newState.rawValue
        clockStatus.currentState = newState
        dc.saveContext()
    }
    
    func getManagedObjectUniqueId() -> UUID {
        return self.managedObject.uniqueId!
    }
    
    func getManagedObject() -> AtcObject {
        return managedObject
    }
    
    func getStatus() -> ClockStatus {
        return clockStatus
    }
    
    func updateName(newName: String) {
        managedObject.name = newName
        dc.saveAndUpdateTimers()
    }
    
}
