//
//  TimerManager.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/23/22.
//

import Foundation

class TimerManager: ObservableObject, AtcManager {
    
    private var timer = Timer()
    let formatter = DateComponentsFormatter()

    private var updateInterval: TimeInterval //Seconds
    private var timerObject: AtcTimer
    private var timeElapsed: TimeInterval = 0
    private var lastUpdate: Date = Date.now

    @Published var clockStatus: ClockStatus
    
    init(updateInterval: TimeInterval, timerObject: AtcTimer) {
        self.updateInterval = updateInterval
        self.timerObject = timerObject
        self.clockStatus = ClockStatus(displayValue:"00:00:00", activated: false, associatedObject: timerObject.uniqueId!)
        self.updateData()
        if (self.timerObject.state == ClockState.ACTIVE.rawValue) {
            self.start()
        } else {
            self.stop()
        }
    }
    
    func start() {
        self.lastUpdate = Date.now
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
            self.updateData()
            let timeSinceLastCheck = -self.lastUpdate.timeIntervalSinceNow
            self.timeElapsed = self.timeElapsed.advanced(by: timeSinceLastCheck)
            self.lastUpdate = Date.now
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
        self.timeElapsed = 0
        self.updateData()
        self.clockStatus.activated = false
        if (!self.timer.isValid && self.timerObject.state == ClockState.ACTIVE.rawValue) {
            self.start()
        }
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
