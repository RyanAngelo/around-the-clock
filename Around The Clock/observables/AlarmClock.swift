//
//  AlarmClock.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/22/22.
//

import Foundation

class AlarmClock: ObservableObject {
    
    private var timer = Timer()
    private var updateInterval: TimeInterval
    private var alarmObject: AtcAlarm
    
    //time remaining in Alarm in seconds
    @Published var timeRemainingSecs: Double = 0;

    init(updateInterval: TimeInterval, alarmObject: AtcAlarm) {
        self.updateInterval = updateInterval
        self.alarmObject = alarmObject
    }
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
            self.updateAlarmData()
        }
    }
    
    func stop() {
        timer.invalidate()
    }
    
    func updateAlarmData() {
        let timeRemainingInterval: TimeInterval = (alarmObject.start_time?.timeIntervalSince(Date.now))!
        timeRemainingSecs = timeRemainingInterval
    }
    
}
