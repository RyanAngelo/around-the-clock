//
//  AlarmConfigView.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/22/22.
//

import SwiftUI

struct AlarmConfigView: View {
    
    @ObservedObject var dc: DataController
    @ObservedObject var selectedObject: AtcAlarm
    
    @State private var selectedDateTime = Date()
    @State private var selectedAudio = AudioFiles.nuts.rawValue
    
    var body: some View {
        VStack {
            HStack {
                DatePicker(
                    "Date & Time",
                    selection: $selectedDateTime,
                    in: Date.now...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.field)
                .help("Select the date and time that you want the alarm to go off")
                Picker("Audio:", selection: $selectedAudio) {
                    ForEach(AudioFiles.allCases) { audio in
                        Text(audio.rawValue.capitalized)
                            .tag(audio.rawValue)
                    }
                    .pickerStyle(.menu)
                    .scaledToFit()
                }
                .help("Select the audio to play when the alarm goes off")
            }
            .padding()
            .background(Color(.systemMint).brightness(0.6))
        }
    }
}

struct AlarmConfigView_Previews: PreviewProvider {
    static var previews: some View {
        let dc: DataController = DataController.preview
        let alarm: AtcAlarm = dc.alarmItems[0]
        ConfigView(dc: dc, selectedObject: alarm)
    }
}
