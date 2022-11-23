//
//  ContentView.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 7/2/22.
//

import SwiftUI
import CoreData

struct OverallView: View {
    
    //Environment passed from parent
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var observableManager: ObservableManager
    
    //Fetch managed object data
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AtcAlarm.name, ascending: true)],
        animation: .default)
    private var alarmItems: FetchedResults<AtcAlarm>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AtcTimer.name, ascending: true)],
        animation: .default)
    private var timerItems: FetchedResults<AtcTimer>

    //State representing currently selected item identifier
    @State private var atcIdentifier: ObjectIdentifier?
    @State private var atcObject: AtcObject?
        
    var body: some View {
        NavigationSplitView {
            List(selection: $atcObject) {
                Section(header: Text("Alarms")) {
                    ForEach(alarmItems) { alarm in
                        NavigationLink(value: alarm) {
                            Text(alarm.name!)
                        }
                    }
                }
                Section(header: Text("Timers")) {
                    ForEach(timerItems) { t in
                        Text(t.name!)
                    }
                }
            }
        } detail: {
            if $atcObject.wrappedValue != nil {
                //Get the selected alarm object
                AlarmDisplayView(alarmObject: $atcObject)
                AlarmMenuView(alarmObject: $atcObject)
            } else {
                Text("Select or create an item")
            }
        }
        .navigationSplitViewStyle(AutomaticNavigationSplitViewStyle())
        .toolbar {
            ToolbarItem {
                Button(action: addAlarm) {
                    Label("Add Alarm", systemImage: "alarm")
                        .labelStyle(VerticalLabelStyle())
                }
            }
            ToolbarItem {
                Button(action: addTimer) {
                    Label("Add Timer", systemImage: "timer")
                        .labelStyle(VerticalLabelStyle())
                }
            }
        }
    }
    
    struct VerticalLabelStyle: LabelStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack {
                configuration.icon.font(.headline)
                configuration.title.font(.subheadline)
            }
        }
    }
    
    private func addAlarm() {
        withAnimation {
            let newItem = AtcAlarm(context: viewContext)
            newItem.stop_time = Date()
            newItem.name = "New Alarm"
            let alarmClock: ClockAlarm = ClockAlarm(updateInterval: 1, alarmObject: newItem)
            observableManager.addManagementObject(observableObject: alarmClock)
            self.saveContext()
        }
    }
    
    private func deleteAlarm(offsets: IndexSet) {
        withAnimation {
            offsets.map { alarmItems[$0] }.forEach(viewContext.delete)
            self.saveContext()
        }
    }
    
    private func addTimer() {
        withAnimation {
            let newItem = AtcTimer(context: viewContext)
            newItem.timeRemaining = 0
            newItem.name = "New Countdown"
            //TODO: Add to ObservableManager
            self.saveContext()
        }
    }
    
    private func deleteTimer(offsets: IndexSet) {
        withAnimation {
            offsets.map { timerItems[$0] }.forEach(viewContext.delete)
            self.saveContext()
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        OverallView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
