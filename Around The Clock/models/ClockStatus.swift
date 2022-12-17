//
//  ClockStatus.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 12/4/22.
//

import Foundation

/**
 ClockStatus keeps track of the information that does not need to be persisted
 in the core data model. Extensions to CoreData models are not advisable
 so this solution keeps them as separate entitites but with the UUID and DataController,
 the data can be easily associated.
 Likewise, the ClockStatus struct can be used to let views know when there has been an updated
 to an alarm that the view cares about
 */
struct ClockStatus {
    var displayValue: String
    var activated: Bool //TODO: Should this be in the ClockState?
    var currentState: ClockState
    var associatedObject: UUID
}
