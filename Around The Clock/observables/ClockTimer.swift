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
    private var objectIdManaged: ObjectIdentifier;
    
    init(updateInterval: TimeInterval, timerObject: AtcTimer) {
        self.updateInterval = updateInterval
        self.timerObject = timerObject
        self.objectIdManaged = timerObject.id
    }
    
    func start() {
        
    }
    
    func stop() {
        
    }
    
    func updateData() {
        
    }
    
    func getManagedIdentifier() -> ObjectIdentifier {
        return self.objectIdManaged
    }
    
    
}
