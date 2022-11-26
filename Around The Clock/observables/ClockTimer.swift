//
//  Timer.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/23/22.
//

import Foundation

class ClockTimer: ObservableObject, ClockObjectProtocol {
    
    private var timer = Timer()
    private var updateInterval: TimeInterval //Seconds
    private var timerObject: AtcTimer
    
    init(updateInterval: TimeInterval, timerObject: AtcTimer) {
        self.updateInterval = updateInterval
        self.timerObject = timerObject
    }
    
    func start() {
        
    }
    
    func stop() {
        
    }
    
    func updateData() {
        
    }
    
    func getManagedObjectUniqueId() -> UUID {
        return self.timerObject.uniqueId!
    }
    
    
}
