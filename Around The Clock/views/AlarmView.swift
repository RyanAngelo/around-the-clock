//
//  ContentView.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 7/2/22.
//

import SwiftUI
import CoreData

struct AlarmView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AtcAlarm.start_time, ascending: true)],
        animation: .default)
    private var items: FetchedResults<AtcAlarm>

    @State private var atcAlarmId: AtcAlarm.ID?
    @State private var atcAlarm: AtcAlarm?
        
    var body: some View {
        NavigationSplitView {
            List(items, selection: $atcAlarmId) { alarm in
                Text(alarm.name!)
            }
        } detail: {
            if let atcAlarmId {
                //Get the selected alarm object
                if let atcAlarm = items.first(where: {$0.id == atcAlarmId}) {
                    Text("\(atcAlarm.debugDescription)")
                    let time: String = "00:00:00" //TODO: Change to time remaining
                    TimeWindowView(timeRemaining: .constant(time));
                } else {
                   Text("Unknown Alarm!")
                }
            } else {
                Text("Select an alarm")
            }
        }
        .toolbar {
            ToolbarItem {
                Button(action: addItem) {
                    Label("Add Alarm", systemImage: "plus")
                }
            }
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = AtcAlarm(context: viewContext)
            newItem.start_time = Date()

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

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

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
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
