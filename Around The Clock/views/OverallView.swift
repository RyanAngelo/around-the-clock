//
//  ContentView.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 7/2/22.
//

import SwiftUI
import CoreData

struct OverallView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var observableManager: ObservableManager
        
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AtcAlarm.name, ascending: true)],
        animation: .default)
    private var alarmItems: FetchedResults<AtcAlarm>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AtcCountdown.name, ascending: true)],
        animation: .default)
    private var countdownItems: FetchedResults<AtcCountdown>


    @State private var atcIdentifier: ObjectIdentifier?
        
    var body: some View {
        NavigationSplitView {
            List(selection: $atcIdentifier) {
                Section(header: Text("Alarms")) {
                    ForEach(alarmItems) { alarm in
                        Text(alarm.name!)
                    }
                }
                Section(header: Text("Countdowns")) {
                    ForEach(countdownItems) { cd in
                        Text(cd.name!)
                    }
                }
            }
        } detail: {
            if let atcIdentifier {
                //Get the selected alarm object
                if let atcAlarm = alarmItems.first(where: {$0.id == atcIdentifier}) {
                    Text("\(atcAlarm.debugDescription)")
                    let time: String = "00:00:00" //TODO: Change to time remaining
                    TimeWindowView(timeRemaining: .constant(time));
                } else if let atcCountdown = countdownItems.first(where: {$0.id == atcIdentifier}) {
                    Text("\(atcCountdown.debugDescription)")
                } else {
                   Text("Unknown Alarm!")
                }
            } else {
                Text("Select an alarm")
            }
        }
        .navigationSplitViewStyle(AutomaticNavigationSplitViewStyle())
        .toolbar {
            ToolbarItem {
                Button(action: addAlarm) {
                    Label("Add Alarm", systemImage: "plus.app")
                        .labelStyle(VerticalLabelStyle())
                }
            }
            ToolbarItem {
                Button(action: addCountdown) {
                    Label("Add Countdown", systemImage: "plus.app")
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
            //TODO: Add to ObservableManager
            self.saveContext()
        }
    }
    
    private func addCountdown() {
        withAnimation {
            let newItem = AtcCountdown(context: viewContext)
            newItem.timeRemaining = 0
            newItem.name = "New Countdown"
            //TODO: Add to ObservableManager
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
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { alarmItems[$0] }.forEach(viewContext.delete)
            self.saveContext()
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
