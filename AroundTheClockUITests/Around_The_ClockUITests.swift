//
//  Around_The_ClockUITests.swift
//  Around The ClockUITests
//
//  Created by Ryan Angelo on 12/27/18.
//  Copyright © 2018 Ryan Angelo. All rights reserved.
//

import XCTest

class Around_The_ClockUITests: XCTestCase {
    
    override func setUp() {
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        let application = XCUIApplication()
        application.launchEnvironment = ["UITESTS":"1"]
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        application.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    func testAlarm() {
        
        let aroundTheClockWindow = XCUIApplication().windows["AroundTheClock"]
        aroundTheClockWindow/*@START_MENU_TOKEN@*/.radioButtons["Alarm"]/*[[".radioGroups.radioButtons[\"Alarm\"]",".radioButtons[\"Alarm\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.click()
        
        let addButton = aroundTheClockWindow/*@START_MENU_TOKEN@*/.buttons["Add"]/*[[".groups.buttons[\"Add\"]",".buttons[\"Add\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        addButton.click()
        
        let textField = aroundTheClockWindow/*@START_MENU_TOKEN@*/.tables/*[[".groups",".scrollViews.tables",".tables"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tableRows.children(matching: .textField).element
        textField.doubleClick()
        textField.typeText("Boop\r")
        aroundTheClockWindow/*@START_MENU_TOKEN@*/.buttons["Start"]/*[[".groups.buttons[\"Start\"]",".buttons[\"Start\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.click()
        aroundTheClockWindow/*@START_MENU_TOKEN@*/.buttons["Stop"]/*[[".groups.buttons[\"Stop\"]",".buttons[\"Stop\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.click()
        aroundTheClockWindow/*@START_MENU_TOKEN@*/.buttons["Properties"]/*[[".groups.buttons[\"Properties\"]",".buttons[\"Properties\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.click()
        aroundTheClockWindow.sheets.buttons["Done"].click()
        addButton.click()
        
        let deleteButton = aroundTheClockWindow/*@START_MENU_TOKEN@*/.buttons["Delete"]/*[[".groups.buttons[\"Delete\"]",".buttons[\"Delete\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        deleteButton.click()
        deleteButton.click()
        
        
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

}
