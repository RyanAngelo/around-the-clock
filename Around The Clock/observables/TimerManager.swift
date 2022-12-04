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

    @Published var clockStatus: ClockStatus
    
    init(updateInterval: TimeInterval, timerObject: AtcTimer) {
        self.updateInterval = updateInterval
        self.timerObject = timerObject
        self.clockStatus = ClockStatus(displayValue:"00:00:00", associatedObject: timerObject.uniqueId!)
        if (self.timerObject.state == ClockState.ACTIVE.rawValue) {
            self.start()
        } else {
            self.stop()
        }
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
        timeElapsed = timeElapsed.advanced(by: updateInterval)
        let timeRemaining: TimeInterval = timeElapsed.advanced(by: -timerObject.stopTime)
        clockStatus.displayValue = formatter.string(from: timeRemaining) ?? "00:00:00"

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
