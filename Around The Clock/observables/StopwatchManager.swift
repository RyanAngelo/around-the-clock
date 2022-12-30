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
class StopwatchManager: ObservableObject, AtcManager{
    
    
    private var timer = Timer()
    private var updateInterval: TimeInterval
    let formatter = DateComponentsFormatter()
    let defaultDisplay: String = "00:00:00.000"
    
    @ObservedObject var dc: DataController
    
    @Published var clockStatus: ClockStatus
    @Published var managedObject: AtcStopwatch
    
    var lapStartTime: Date?
    
    init(dc: DataController, updateInterval: TimeInterval, stopwatchObject: AtcStopwatch) {
        self.dc = dc
        self.updateInterval = updateInterval
        self.managedObject = stopwatchObject
        self.clockStatus = ClockStatus(displayValue:defaultDisplay, activated: true, associatedObject: stopwatchObject.uniqueId!)
        if (self.managedObject.state == ClockState.ACTIVE.rawValue) {
            self.start()
        } else {
            self.stop()
        }
    }
    
    //TODO: Make sure that this runs when window minimized
    func start() {
        self.lapStartTime = Date.now
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
            self.updateData()
        }
    }
    
    func stop() {
        timer.invalidate()
    }
    
    func updateData() {
        if (self.managedObject.state == ClockState.ACTIVE.rawValue || self.managedObject.state == ClockState.PAUSED.rawValue) {
            let timeElapsed: TimeInterval = -(managedObject.startTime?.timeIntervalSinceNow)!
            clockStatus.displayValue = stringFromTime(interval: timeElapsed)
        } else {
            clockStatus.displayValue = defaultDisplay
        }
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
    
    func resetFastestLap() {
        let laps: [AtcLap] = getLaps()
        laps.forEach {  $0.fastest = false }
    }
    
    func resetSlowestLap() {
        let laps: [AtcLap] = getLaps()
        laps.forEach {  $0.slowest = false }
    }
    
    func getFastestLap() -> AtcLap? {
        let laps: [AtcLap] = getLaps()
        let fastestLap = laps.min { $0.timeInterval < $1.timeInterval }
        return fastestLap
    }
    
    func getSlowestLap() -> AtcLap? {
        let laps: [AtcLap] = getLaps()
        let slowestLap = laps.max { $0.timeInterval < $1.timeInterval }
        return slowestLap
    }
    
    func getLaps() -> [AtcLap] {
        let laps: [AtcLap] = self.managedObject.laps?.array as? [AtcLap] ?? []
        return laps
    }
    
    func updateFastestAndSlowestLaps() {
        resetFastestLap()
        resetSlowestLap()
        let fastestLap: AtcLap? = getFastestLap()
        let slowestLap: AtcLap? = getSlowestLap()
        fastestLap?.fastest = true
        if (fastestLap != slowestLap) {
            slowestLap?.slowest = true
        }
    }
    
    func addLap() {
        let lapTime: TimeInterval = -(lapStartTime?.timeIntervalSinceNow)!
        dc.addLap(stopwatch: self.managedObject, newLapTime: lapTime)
        self.updateFastestAndSlowestLaps()
        self.lapStartTime = Date.now
    }
    
    func setManagedObjectState(newState: ClockState) {
        if (managedObject.state == ClockState.STOPPED.rawValue && newState == ClockState.ACTIVE) {
            self.managedObject.startTime = Date.now
        }
        managedObject.state = newState.rawValue
        dc.saveContext()
        if (newState == ClockState.ACTIVE) {
            start()
        } else if (newState == ClockState.STOPPED || newState == ClockState.PAUSED) {
            stop()
        }
        updateData() //Update data after stopwatch stops
    }
    
    func reset() {
        setManagedObjectState(newState: ClockState.STOPPED)
        self.managedObject.laps = []
        dc.saveContext()
    }
    
    func stringFromTime(interval: TimeInterval) -> String {
        let ms = Int(interval.truncatingRemainder(dividingBy: 1) * 1000)
        let msString = String(format: "%03d", ms)
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: interval)! + ".\(msString)"
    }

    
    func triggerActivation() {}
    func endActivation() {}
    
}
