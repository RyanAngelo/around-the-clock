//
//  ClockObjectProtocol.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/22/22.
//

import Foundation

/**
 Protocol for defining the management objects that handle the logic behind
 different models, such as alarm clock, timer, stopwatch
 */
protocol AtcManager: ObservableObject {
    
    var dc: DataController { get set }
    func start()
    func stop()
    //Update the data in the manager
    func updateData()
    //Get the UUID of the associated managed ATC object
    func getManagedObjectUniqueId() -> UUID
    //Returns the associated managed ATC object
    func getManagedObject() -> AtcObject
    //Returns the associated ClockStatus object
    func getStatus() -> ClockStatus
    //Reset the manager to the initial state
    func reset()
    //Set the current state of the object (Active/Paused, etc.)
    func setManagedObjectState(newState: ClockState)
    
}
