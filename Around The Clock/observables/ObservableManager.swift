//
//  ObservableManager.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/22/22.
//

import Foundation

/**
 ObservableManager manages ObservableObjects
 The Observable objects include AlarmClock, StopWatch, etc.
 Multiple instances of each can be present at any given time and the
 ObservableManager keeps track of them. They are acquired by
 knowing the Identifier of the underlying object (e.g. AtcAlarm, AtcStopwatch)
 */
class ObservableManager: ObservableObject {
    
    var managementDictionary: [ObjectIdentifier: ClockObjectProtocol] = [:]
    
    init(){
        
    }
    
    public func addManagementObject(observableObject: ClockAlarm) {
        managementDictionary.updateValue(observableObject, forKey: observableObject.getManagedIdentifier())
    }
    
    public func removeManagementObject(objIdToRemove: ObjectIdentifier) {
        self.managementDictionary.removeValue(forKey: objIdToRemove)
    }
}
