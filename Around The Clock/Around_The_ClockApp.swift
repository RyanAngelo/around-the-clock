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
            OverallView(dc: self.dc)
                .environment(\.managedObjectContext, dc.container.viewContext)
        }
    }
}
