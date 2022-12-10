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
    @Published var currentState: ClockState
    
    //TODO: Should I just publish timerObject?
    @Published var timerObject: AtcTimer
        
    init(dc: DataController, updateInterval: TimeInterval, timerObject: AtcTimer) {
        self.dc = dc
        self.updateInterval = updateInterval
        self.timerObject = timerObject
        self.clockStatus = ClockStatus(displayValue:"00:00:00", activated: false, associatedObject: timerObject.uniqueId!)
        self.hours = TimerManager.getHours(countdownTime: timerObject.stopTime)
        self.minutes = TimerManager.getMinutes(countdownTime: timerObject.stopTime)
        self.seconds = TimerManager.getSeconds(countdownTime: timerObject.stopTime)
        self.currentState = ClockState(rawValue: timerObject.state) ?? ClockState.STOPPED
        self.updateData()
        if (self.timerObject.state == ClockState.ACTIVE.rawValue) {
            self.start()
        } else {
            self.stop()
        }
    }
    
    func start() {
        self.timerObject.lastCheckDate = Date.now
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
            self.updateData()
            let timeSinceLastCheck = -self.timerObject.lastCheckDate!.timeIntervalSinceNow
            self.timeElapsed = self.timeElapsed.advanced(by: timeSinceLastCheck)
            self.timerObject.lastCheckDate = Date.now
        }
    }
    
    func stop() {
        timer.invalidate()
    }
    
    func updateData() {
        let timeRemaining: TimeInterval = timerObject.stopTime.advanced(by: -timeElapsed)
        if (timeRemaining <= 0) {
            clockStatus.activated = true
            self.timer.invalidate()
        }
        clockStatus.displayValue = formatter.string(from: timeRemaining) ?? "00:00:00"
    }
    
    func reset() {
        self.stop()
        self.timeElapsed = 0
        self.updateData()
        self.clockStatus.activated = false
        if (!self.timer.isValid && self.timerObject.state == ClockState.ACTIVE.rawValue) {
            self.start()
        }
    }
    
    func assignHoursMinutesSeconds() {
        hours = TimerManager.getHours(countdownTime: timerObject.stopTime)
        minutes = TimerManager.getMinutes(countdownTime: timerObject.stopTime)
        seconds = TimerManager.getSeconds(countdownTime: timerObject.stopTime)
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
        timerObject.stopTime =
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
        timerObject.state = newState.rawValue
        currentState = newState
        dc.saveContext()
    }
    
    func getManagedObjectUniqueId() -> UUID {
        return self.timerObject.uniqueId!
    }
    
    func getManagedObject() -> AtcObject {
        return timerObject
    }
    
    func getStatus() -> ClockStatus {
        return clockStatus
    }
    
}
