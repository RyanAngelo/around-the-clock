//
//  State.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/22/22.
//

import Foundation

@objc
public enum ClockState: Int16 {
    case ACTIVE = 0
    case PAUSED = 1
    case STOPPED = 2
    case TRIGGERED = 3
}
