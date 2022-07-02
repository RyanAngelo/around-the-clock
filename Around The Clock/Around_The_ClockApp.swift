//
//  Around_The_ClockApp.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 7/2/22.
//

import SwiftUI

@main
struct Around_The_ClockApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
