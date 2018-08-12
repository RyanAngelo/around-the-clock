//
//  Around_The_ClockTests.swift
//  Around The ClockTests
//
//  Created by Ryan Angelo on 11/1/14.
//  Copyright (c) 2018 Ryan Angelo. All rights reserved.
//

import Cocoa
import XCTest
@testable import Around_The_Clock

class Around_The_ClockTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testObjectCreation() {
        let alarm = Alarm()
        alarm.setState(off: "paused")
        XCTAssertEqual(alarm.alarmstate, "paused")
        let watch = Watch()
        watch.setState(off: "paused")
        XCTAssertEqual(alarm.alarmstate, "paused")
        let countdown = Countdown()
        countdown.setState(off: "paused")
        XCTAssertEqual(countdown.countdownstate, "paused")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
