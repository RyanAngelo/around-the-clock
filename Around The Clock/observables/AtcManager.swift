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
    
}
