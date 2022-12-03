//
//  AlarmClock.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/22/22.
//

import Foundation

/**
 AlarmClock manages a single alarm
 The AlarmClock calculates the time remaining
 The AlarmClock is tied to an alarmObject
 */
class ClockAlarm: ClockObjectProtocol {
    
    private var timer = Timer()
    private var alarmObject: AtcAlarm
    private var updateInterval: TimeInterval

    var timeRemainingString: String = "00:00:00"

    init(updateInterval: TimeInterval, alarmObject: AtcAlarm) {
        self.updateInterval = updateInterval
        self.alarmObject = alarmObject
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
        let timeRemainingInterval: TimeInterval = (alarmObject.stopTime?.timeIntervalSince(Date.now))!
        //TODO: Update with a nicely formatted time remaining HH:MM:SS
        timeRemainingString = timeRemainingInterval.description
    }
    
    func getManagedObjectUniqueId() -> UUID {
        return self.alarmObject.uniqueId!
    }
    
    func getDisplayText() -> String {
        return self.timeRemainingString
    }
    
}
