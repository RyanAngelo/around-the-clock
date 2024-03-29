//
//  AlarmConfigView.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/22/22.
//

import SwiftUI

struct TimerConfigView: View {
    
    let hours: Array<Int> = Array(0...23)
    let minutes: Array<Int> = Array(0...59)
    let seconds: Array<Int> = Array(0...59)
    
    @ObservedObject var selectedManager: TimerManager
    
    var body: some View {
        VStack {
            VStack {
                Picker("Hours".padding(toLength: 9, withPad: " ", startingAt: 0), selection: $selectedManager.hours ) {
                    ForEach(hours, id: \.self) { hour in
                        Text(hour.description)
                    }
                }
                Picker("Minutes".padding(toLength: 9, withPad: " ", startingAt: 0), selection: $selectedManager.minutes) {
                    ForEach(minutes, id: \.self) { minute in
                        Text(minute.description)
                    }
                }
                Picker("Seconds".padding(toLength: 9, withPad: " ", startingAt: 0), selection: $selectedManager.seconds) {
                    ForEach(seconds, id: \.self) { second in
                        Text(second.description)
                    }
                }
            }
                .monospaced()
            .onChange(of: selectedManager.hours, perform: { (value) in
                selectedManager.setManagedObjectTime()
            })
            .onChange(of: selectedManager.minutes, perform: { (value) in
                selectedManager.setManagedObjectTime()
            })
            .onChange(of: selectedManager.seconds, perform: { (value) in
                selectedManager.setManagedObjectTime()
            })
            .padding()
            Picker("Audio:", selection: $selectedManager.managedObject.audioFile.toUnwrapped(defaultValue: AudioFiles.SimpleBells.rawValue)) {
                ForEach(AudioFiles.allCases) { audio in
                    Text(audio.rawValue)
                        .tag(audio.rawValue)
                }
                .pickerStyle(.menu)
            }
            .onChange(of: selectedManager.managedObject.audioFile, perform: { (value) in
                selectedManager.audioHasChanged()
            })
            .help("Select the audio to play when the alarm goes off")
            .padding()
            .monospaced()
            HStack {
                if (selectedManager.managedObject.state != ClockState.ACTIVE.rawValue) {
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
    }
    
    func start() {
        selectedManager.setManagedObjectState(newState: ClockState.ACTIVE)
    }
    
    func stop() {
        selectedManager.setManagedObjectState(newState: ClockState.PAUSED)
    }
    
    func reset() {
        selectedManager.reset()
    }
    
}

struct TimerConfigView_Previews: PreviewProvider {
    static var previews: some View {
        let dc: DataController = DataController.preview
        let manager: TimerManager = dc.getManager(uniqueIdentifier: dc.timerItems[0].uniqueId!) as! TimerManager
        TimerConfigView(selectedManager: manager)
    }
}
