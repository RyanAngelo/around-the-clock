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
class ClockAlarm: ObservableObject, ClockObjectProtocol {
    
    private var timer = Timer()
    private var updateInterval: TimeInterval //Seconds
    private var alarmObject: AtcAlarm
    private var objectIdManaged: ObjectIdentifier;
    
    //time remaining in Alarm in seconds
    @Published var timeRemainingSecs: Double = 0;

    init(updateInterval: TimeInterval, alarmObject: AtcAlarm) {
        self.updateInterval = updateInterval
        self.alarmObject = alarmObject
        self.objectIdManaged = alarmObject.id
    }
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
            self.updateData()
        }
    }
    
    func stop() {
        timer.invalidate()
    }
    
    func updateData() {
        let timeRemainingInterval: TimeInterval = (alarmObject.stop_time?.timeIntervalSince(Date.now))!
        timeRemainingSecs = timeRemainingInterval
    }
    
    func getManagedIdentifier() -> ObjectIdentifier {
        return self.alarmObject.id
    }
    
}
