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
    
    var alarm: Alarm? = nil
    var watch: Watch? = nil
    var countdown: Countdown? = nil
    var context: NSManagedObjectContext? = nil
    
    override func setUp() {
        super.setUp()
        self.context = setUpInMemoryManagedObjectContext()
        alarm = Alarm(context: self.context!)
        alarm!.name = "Test Alarm"
        watch = Watch(context: self.context!)
        watch!.name = "Test Watch"
        countdown = Countdown(context: self.context!)
        countdown!.name = "Test Countdown"
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func setUpInMemoryManagedObjectContext() -> NSManagedObjectContext {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        } catch {
            print("Adding in-memory persistent store failed")
        }
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        return managedObjectContext
    }//setUpInMemoryManagedObjectContext
    
    func testObjectCreation() {
        alarm?.setState(state: "off")
        XCTAssertEqual(alarm!.alarmstate, "off")
        watch?.setState(state: "off")
        XCTAssertEqual(watch!.watchstate, "off")
        countdown?.setState(state: "off")
        XCTAssertEqual(countdown!.countdownstate, "off")
    }
    
}
