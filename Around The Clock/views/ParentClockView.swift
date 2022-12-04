//
//  ContentView.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 7/2/22.
//

import SwiftUI
import CoreData

struct ParentClockView: View {
    
    //Environment passed from parent
    @ObservedObject var dc: DataController

    //State representing currently selected item identifier
    @State private var atcObject: AtcObject?
    @State private var selectedObjectId: ObjectIdentifier?
    
    var body: some View {
        NavigationSplitView {
            List(selection: $atcObject) {
                Section(header: Text("Alarms")) {
                    ForEach(dc.alarmItems) { alarm in
                        NavigationLink(value: alarm) {
                            Text(alarm.name ?? "Unknown Alarm")
                        }
                    }
                }
                Section(header: Text("Timers")) {
                    ForEach(dc.timerItems) { t in
                        NavigationLink(value: t) {
                            Text(t.name ?? "Unknown Timer")
                        }
                    }
                }
            }
        } detail: {
            if $atcObject.wrappedValue != nil {
                //Get the selected alarm object
                TitleView(dc: dc, selectedObject: atcObject!)
                StatusView(dc: dc, uid: (atcObject?.uniqueId)!)
                ConfigView(dc: dc, selectedObject: atcObject!)
            } else {
                Text("Select or create an item")
            }
        }
        .navigationSplitViewStyle(AutomaticNavigationSplitViewStyle())
        .toolbar {
            ToolbarItem {
                Button(action: dc.addAlarm) {
                    Label("Add Alarm", systemImage: "alarm")
                        .labelStyle(VerticalLabelStyle())
                }
            }
            ToolbarItem {
                Button(action: dc.addTimer) {
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
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ParentClockView_Previews: PreviewProvider {
    static var previews: some View {
        let dc: DataController = DataController.preview
        ParentClockView(dc: dc)
    }
}
