//
//  AlarmConfigView.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/22/22.
//

import SwiftUI

struct TimerConfigView: View {
    
    @ObservedObject var dc: DataController
    @ObservedObject var selectedObject: AtcTimer
    
    var body: some View {
        VStack {
            HStack {
                /*
                DatePicker(
                    "Date & Time",
                    selection: $selectedObject.stopTime.toUnwrapped(defaultValue: Date.now.addingTimeInterval(60*60)),
                    in: Date.now...,
                    displayedComponents: [.date, .hourAndMinute] )
                .datePickerStyle(.field)
                .help("Select the date and time that you want the alarm to go off")
                .onChange(of: selectedObject.stopTime, perform: { (value) in
                    //When the date is changed, save the context CoreData
                    dc.saveContext()
                })*/
            }
        }
        HStack {
            if (selectedObject.state != ClockState.ACTIVE.rawValue && selectedObject.state != ClockState.TRIGGERED.rawValue) {
                Button(action: start) {
                    Text("Start")
                        .padding()
                        .frame(width: 70, height: 30, alignment: .center)
                        .background(RoundedRectangle(cornerRadius: 8)
                            .fill(Color.green))
                        .font(.system(.title3))
                }.buttonStyle(PlainButtonStyle())
                    
            } else {
                Button(role: .cancel, action: stop) {
                    Text("Stop")
                        .padding()
                        .frame(width: 70, height: 30, alignment: .center)
                        .background(RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red))
                        .font(.system(.title3))
                }.buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        
    }
    
    func start() {
        dc.setManagerState(atcObject: selectedObject, newState: ClockState.ACTIVE)
    }
    
    func stop() {
        dc.setManagerState(atcObject: selectedObject, newState: ClockState.PAUSED)
    }
    
}

struct TimerConfigView_Previews: PreviewProvider {
    static var previews: some View {
        let dc: DataController = DataController.preview
        //index 0 is an active alarm, index 3 is a paused alarm
        let timer: AtcTimer = dc.timerItems[0]
        TimerConfigView(dc: dc, selectedObject: timer)
    }
}
