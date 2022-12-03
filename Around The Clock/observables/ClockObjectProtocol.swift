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
protocol ClockObjectProtocol: ObservableObject {
    
    func start()
    func stop()
    func updateData()
    func getManagedObjectUniqueId() -> UUID
    func getDisplayText() -> String
    
    var timeRemainingString: String { get set }
}
