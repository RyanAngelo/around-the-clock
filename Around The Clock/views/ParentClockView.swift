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
    
    init(dc: DataController, atcObject: AtcObject?) {
        self.dc = dc
        //atcObject is needed for previews
        self._atcObject = State(initialValue: atcObject ?? nil)
    }
        
    var body: some View {
        NavigationSplitView {
            List(selection: $atcObject) {
                AlarmSectionView(dc: dc, atcObject: $atcObject)
                TimerSectionView(dc: dc, atcObject: $atcObject)
                StopwatchSectionView(dc: dc, atcObject: $atcObject)
            }
        } detail: {
            if $atcObject.wrappedValue != nil {
                VStack {
                    TitleView(dc: dc, selectedObject: atcObject!)
                    Spacer()
                    if atcObject! is AtcAlarm {
                        AlarmView(dc: dc, atcObject: atcObject!)
                    } else if atcObject! is AtcTimer {
                        TimerView(dc: dc, atcObject: atcObject!)
                    } else if atcObject! is AtcStopwatch {
                        StopwatchView(dc: dc, atcObject: atcObject!)
                    }
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
                dc.endAlert(alertNumber: 1, activeAlert: dc.activeAlert1!)
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
                dc.endAlert(alertNumber: 2, activeAlert: dc.activeAlert2!)
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
        let alarmObject = dc.alarmItems[0]
        let pcw = ParentClockView(dc: dc, atcObject: alarmObject)
        return pcw
    }
}
