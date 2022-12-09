//
//  AlarmConfigView.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/22/22.
//

import SwiftUI

struct TimerConfigView: View {
    
    let hours = Array(0...23)
    let minutes = Array(0...59)
    let seconds = Array(0...59)
    
    @ObservedObject var dc: DataController
    @ObservedObject var selectedObject: AtcTimer
    
    @State private var selectedHours: Int
    @State private var selectedMinutes: Int
    @State private var selectedSeconds: Int
    
    init(dc: DataController, selectedObject: AtcTimer) {
        self.dc = dc
        self.selectedObject = selectedObject
        self.selectedHours = TimerConfigView.getHours(countdownTime: selectedObject.stopTime)
        self.selectedMinutes = TimerConfigView.getMinutes(countdownTime: selectedObject.stopTime)
        self.selectedSeconds = TimerConfigView.getSeconds(countdownTime: selectedObject.stopTime)
        self.assignHoursMinutesSeconds()
    }
    
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
        }.padding()
            .onChange(of: selectedHours, perform: { (value) in
                setManagedObjectTime()
                dc.updateTimerManager(id: selectedObject.uniqueId!)
            })
            .onChange(of: selectedMinutes, perform: { (value) in
                setManagedObjectTime()
                dc.updateTimerManager(id: selectedObject.uniqueId!)
            })
            .onChange(of: selectedSeconds, perform: { (value) in
                setManagedObjectTime()
                dc.updateTimerManager(id: selectedObject.uniqueId!)
            })
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
                    Text("Pause")
                        .padding()
                        .frame(width: 75, height: 30, alignment: .center)
                        .background(RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red))
                        .font(.system(.title3))
                }.buttonStyle(PlainButtonStyle())
            }
            Button(role: .cancel, action: reset) {
                Text("Reset")
                    .padding()
                    .frame(width: 75, height: 30, alignment: .center)
                    .background(RoundedRectangle(cornerRadius: 8)
                        .fill(Color.yellow))
                    .font(.system(.title3))
            }.buttonStyle(PlainButtonStyle())
        }
        .padding()
        
    }
    
    func setManagedObjectTime() {
        selectedObject.stopTime =
        Double(selectedHours * 60 * 60 +
               selectedMinutes * 60 +
               selectedSeconds)
    }
    
    func assignHoursMinutesSeconds() {
        selectedHours = TimerConfigView.getHours(countdownTime: selectedObject.stopTime)
        selectedMinutes = TimerConfigView.getMinutes(countdownTime: selectedObject.stopTime)
        selectedSeconds = TimerConfigView.getSeconds(countdownTime: selectedObject.stopTime)
    }
    
    static func getHours(countdownTime: Double) -> Int {
        return Int(countdownTime / 3600)
    }
    
    static func getMinutes(countdownTime: Double) -> Int {
        return Int((countdownTime.truncatingRemainder(dividingBy: 3600)) / 60)
    }
    
    static func getSeconds(countdownTime: Double) -> Int {
        return Int((countdownTime.truncatingRemainder(dividingBy: 3600)).truncatingRemainder(dividingBy: 60))
    }
    
    func start() {
        dc.setManagerState(atcObject: selectedObject, newState: ClockState.ACTIVE)
    }
    
    func stop() {
        dc.setManagerState(atcObject: selectedObject, newState: ClockState.PAUSED)
    }
    
    func reset() {
        dc.resetManager(atcObject: selectedObject)
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
