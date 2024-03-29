//
//  AlarmConfigView.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/22/22.
//

import SwiftUI

struct AlarmConfigView: View {
    
    @ObservedObject var selectedManager: AlarmManager
    
    var body: some View {
        VStack {
            HStack {
                DatePicker(
                    "Date & Time",
                    selection: $selectedManager.managedObject.stopTime.toUnwrapped(defaultValue: Date.now.addingTimeInterval(60*60)),
                    in: Date.now...,
                    displayedComponents: [.date, .hourAndMinute] )
                .datePickerStyle(.field)
                .help("Select the date and time that you want the alarm to go off")
                .onChange(of: selectedManager.managedObject.stopTime!, perform: { _ in
                    selectedManager.managedObject.stopTime = selectedManager.managedObject.stopTime!.startOfMinute()
                    selectedManager.dateHasChanged()
                })
                Picker("Audio:", selection: $selectedManager.managedObject.audioFile.toUnwrapped(defaultValue: AudioFiles.SimpleBells.rawValue)) {
                    ForEach(AudioFiles.allCases) { audio in
                        Text(audio.rawValue)
                        .tag(audio.rawValue)
                    }
                    .pickerStyle(.menu)
                    .scaledToFit()
                }
                .onChange(of: selectedManager.managedObject.audioFile, perform: { (value) in
                    selectedManager.audioHasChanged()
                })
                .help("Select the audio to play when the alarm goes off")
            }
            .monospaced()
            .padding()
        }
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
        .help(Text("Configure an alarm by settings the desired completion date and time."))
    }
    
    func start() {
        selectedManager.setManagedObjectState(newState: ClockState.ACTIVE)
    }
    
    func stop() {
        selectedManager.setManagedObjectState(newState: ClockState.PAUSED)
    }
    
}

struct AlarmConfigView_Previews: PreviewProvider {
    static var previews: some View {
        let dc: DataController = DataController.preview
        let manager: AlarmManager = dc.getManager(uniqueIdentifier: dc.alarmItems[0].uniqueId!) as! AlarmManager
        AlarmConfigView(selectedManager: manager)
    }
}
