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
                    selectedManager.dateHasChanged()
                })
                Picker("Audio:", selection: $selectedManager.managedObject.audioFile.toUnwrapped(defaultValue: AudioFiles.nuts.rawValue)) {
                    ForEach(AudioFiles.allCases) { audio in
                        Text(audio.rawValue.capitalized)
                            .tag(audio.rawValue)
                    }
                    .pickerStyle(.menu)
                    .scaledToFit()
                }
                .onChange(of: selectedManager.managedObject.audioFile, perform: { (value) in
                    //When the date is changed, save the context CoreData
                    //TODO: Save audio change
                })
                .help("Select the audio to play when the alarm goes off")
            }
            .padding()
        }
        HStack {
            if (selectedManager.clockStatus.currentState != ClockState.ACTIVE) {
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
