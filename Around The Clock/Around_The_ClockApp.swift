//
//  Around_The_ClockApp.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 7/2/22.
//

import SwiftUI

@main
struct Around_The_ClockApp: App {
    @StateObject private var dc = DataController()
    
    var body: some Scene {
        //managedObjectContext = "live" version of data
        WindowGroup {
            ParentClockView(dc: self.dc, atcObject: nil)
                .environment(\.managedObjectContext, dc.container.viewContext)
        }
        .commands {
            CommandMenu("Add Item") {
                Button("Add Alarm") {
                    dc.addAlarm()
                }
                Button("Add Timer") {
                    dc.addTimer()
                }
                Button("Add Stopwatch") {
                    dc.addStopwatch()
                }
            }
        }
    }
}
