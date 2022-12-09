//
//  AlarmManager.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/22/22.
//

import Foundation

/**
 AlarmManager manages a single alarm
 The AlarmManager calculates the time remaining
 The AlarmManager is tied to an alarmObject
 */
class AlarmManager: ObservableObject, AtcManager{
            
    private var timer = Timer()
    private var alarmObject: AtcAlarm
    private var updateInterval: TimeInterval
    let formatter = DateComponentsFormatter()
    
    @Published var clockStatus: ClockStatus

    init(updateInterval: TimeInterval, alarmObject: AtcAlarm) {
        self.updateInterval = updateInterval
        self.alarmObject = alarmObject
        self.clockStatus = ClockStatus(displayValue:"00:00:00", activated: true, associatedObject: alarmObject.uniqueId!)
        if (self.alarmObject.state == ClockState.ACTIVE.rawValue) {
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
        let timeRemainingInterval: TimeInterval = (alarmObject.stopTime?.timeIntervalSince(Date.now))!
        clockStatus.displayValue = formatter.string(from: timeRemainingInterval) ?? "00:00:00"
    }
    
    func getManagedObjectUniqueId() -> UUID {
        return self.alarmObject.uniqueId!
    }
    
    func getStatus() -> ClockStatus {
        return self.clockStatus
    }
    
    func getManagedObject() -> AtcObject {
        return alarmObject
    }
    
    func reset() {}
    
}
