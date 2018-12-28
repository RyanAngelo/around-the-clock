//
//  Operations.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/9/14.
//  Copyright (c) 2014 Ryan Angelo. All rights reserved.
//

import Foundation

class Operations {
    
    lazy var alarmsInProgress = Dictionary<NSIndexPath,NSOperation>()
    lazy var alarmQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Alarm Queue"
        return queue
    }()

    lazy var stopwatchInProgress = Dictionary<NSIndexPath,NSOperation>()
    lazy var stopwatchQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Stopwatch Queue"
        return queue
        }()
    
    lazy var countdownInProgress = Dictionary<NSIndexPath,NSOperation>()
    lazy var countdownQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Countdown Queue"
        return queue
        }()
    
}