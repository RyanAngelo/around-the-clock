//
//  ContentView.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 7/2/22.
//

import SwiftUI
import CoreData

//ParentClockView pulls all the other views together.
//This is the only view that should need to direclty use the DataController
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
                            HStack {
                                Text(alarm.name ?? "Unknown Alarm")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                if (alarm.isEqual(to: atcObject)) {
                                    Button(action: {deleteObject(objectToDelete: alarm) }) {
                                        Label("", systemImage: "minus.circle")
                                            .labelStyle(IconOnlyLabelStyle())
                                            .foregroundColor(Color(.white))
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                            }
                        }
                    }
                }
                Section(header: Text("Timers")) {
                    ForEach(dc.timerItems) { timer in
                        NavigationLink(value: timer) {
                            HStack {
                                Text(timer.name ?? "Unknown Timer")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                if (timer.isEqual(to: atcObject)) {
                                    Button(action: {deleteObject(objectToDelete: timer) }) {
                                        Label("", systemImage: "minus.circle")
                                            .labelStyle(IconOnlyLabelStyle())
                                            .foregroundColor(Color(.white))
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                            }
                        }
                    }
                }
                Section(header: Text("Stopwatches")) {
                    ForEach(dc.stopwatchItems) { stopwatch in
                        NavigationLink(value: stopwatch) {
                            HStack {
                                Text(stopwatch.name ?? "Unknown Stopwatch")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                if (stopwatch.isEqual(to: atcObject)) {
                                    Button(action: {deleteObject(objectToDelete: stopwatch) }) {
                                        Label("", systemImage: "minus.circle")
                                            .labelStyle(IconOnlyLabelStyle())
                                            .foregroundColor(Color(.white))
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                            }
                        }
                    }
                }
            }
        } detail: {
            if $atcObject.wrappedValue != nil {
                if atcObject! is AtcAlarm {
                    TitleView(dc: dc, selectedObject: atcObject!)
                    AlarmStatusView(selectedManager: dc.getManager(uniqueIdentifier: (atcObject?.uniqueId)!) as! AlarmManager)
                    AlarmConfigView(selectedManager: dc.getManager(uniqueIdentifier: (atcObject?.uniqueId)!) as! AlarmManager)
                } else if atcObject! is AtcTimer {
                    TitleView(dc: dc, selectedObject: atcObject!)
                    TimerStatusView(selectedManager: dc.getManager(uniqueIdentifier: (atcObject?.uniqueId)!) as! TimerManager)
                    TimerConfigView(selectedManager: dc.getManager(uniqueIdentifier: (atcObject?.uniqueId)!) as! TimerManager)
                } else if atcObject! is AtcStopwatch {
                    TitleView(dc: dc, selectedObject: atcObject!)
                    StopwatchStatusView(selectedManager: dc.getManager(uniqueIdentifier: (atcObject?.uniqueId)!) as! StopwatchManager)
                    StopwatchConfigView(selectedManager: dc.getManager(uniqueIdentifier: (atcObject?.uniqueId)!) as! StopwatchManager)
                }
            } else {
                Text("Select or create an item")
            }
        } //We support displaying two alerts at once so that we can queue up additional alerts
        .alert(
            "Done!",
            isPresented: $dc.alert1Present,
            presenting: dc.activeAlert1
        ) { activeAlert in
            Text(activeAlert.associatedObject.name! + " has completed.")
            Button() {
                dc.endAlert1(activeAlert: dc.activeAlert1!)
            } label: {
                Text("End")
            }
        } message: { activeAlert in
            Text(activeAlert.associatedObject.name! + " has completed.")
        }
        .alert(
            "Done!",
            isPresented: $dc.alert2Present,
            presenting: dc.activeAlert2
        ) { activeAlert in
            Text(activeAlert.associatedObject.name! + " has completed.")
            Button() {
                dc.endAlert2(activeAlert: dc.activeAlert2!)
            } label: {
                Text("End")
            }
        } message: { activeAlert in
            Text(activeAlert.associatedObject.name! + " has completed.")
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
            ToolbarItem {
                Button(action: dc.addStopwatch) {
                    Label("Add Stopwatch", systemImage: "stopwatch")
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
    
    private func deleteObject(objectToDelete: AtcObject) {
        atcObject = nil
        dc.deleteManagedObject(atcObject: objectToDelete)
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
