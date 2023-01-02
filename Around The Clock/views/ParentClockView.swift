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
                AlarmSectionView(dc: dc, atcObject: $atcObject)
                TimerSectionView(dc: dc, atcObject: $atcObject)
                StopwatchSectionView(dc: dc, atcObject: $atcObject)
            }
        } detail: {
            if $atcObject.wrappedValue != nil {
                TitleView(dc: dc, selectedObject: atcObject!)
                if atcObject! is AtcAlarm {
                    AlarmStatusView(selectedManager: dc.getManager(uniqueIdentifier: (atcObject?.uniqueId)!) as! AlarmManager)
                    AlarmConfigView(selectedManager: dc.getManager(uniqueIdentifier: (atcObject?.uniqueId)!) as! AlarmManager)
                } else if atcObject! is AtcTimer {
                    TimerStatusView(selectedManager: dc.getManager(uniqueIdentifier: (atcObject?.uniqueId)!) as! TimerManager)
                    TimerConfigView(selectedManager: dc.getManager(uniqueIdentifier: (atcObject?.uniqueId)!) as! TimerManager)
                } else if atcObject! is AtcStopwatch {
                    StopwatchStatusView(selectedManager: dc.getManager(uniqueIdentifier: (atcObject?.uniqueId)!) as! StopwatchManager)
                    StopwatchConfigView(selectedManager: dc.getManager(uniqueIdentifier: (atcObject?.uniqueId)!) as! StopwatchManager)
                }
            } else {
                Text("Select or create an item")
            }
        }
        // There is a limitation in SwiftUI preview that two alerts can't be present
        // in the same level of the view hierarchy, so we assign them to empty Text.
        Text("")
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
        Text("")
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
