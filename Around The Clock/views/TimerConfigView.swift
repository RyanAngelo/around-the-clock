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
    
    let hours = Array(0...23)
    let minutes = Array(0...59)
    let seconds = Array(0...59)
    
    @State private var selectedHours: Int = 0
    @State private var selectedMinutes: Int = 0
    @State private var selectedSeconds: Int = 0
    
    var body: some View {
        HStack {
            Picker("Hours", selection: $selectedHours) {
                ForEach(hours, id: \.self) { hour in
                    Text(hour.description)
                }
            }
            Picker("Minutes", selection: $selectedMinutes) {
                ForEach(minutes, id: \.self) { minute in
                    Text(minute.description)
                }
            }
            Picker("Seconds", selection: $selectedSeconds) {
                ForEach(seconds, id: \.self) { second in
                    Text(second.description)
                }
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
