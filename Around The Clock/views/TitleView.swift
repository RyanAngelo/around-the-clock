//
//  TitleView.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 12/3/22.
//

import SwiftUI

struct TitleView: View {
    
    @ObservedObject var dc: DataController
    @ObservedObject var selectedObject: AtcObject
    
    var body: some View {
        TextField("Name",
                  text: $selectedObject.name.toUnwrapped(defaultValue: "Unknown"),
                  onCommit: { dc.saveContext() }
        )
        .multilineTextAlignment(.center)
        .font(.largeTitle)
        .padding()
        .onChange(of: selectedObject.name, perform: { (value) in
            if selectedObject is AtcAlarm {
                dc.saveAndUpdateAlarms()
            } else if selectedObject is AtcTimer {
                dc.saveAndUpdateTimers()
            }
        })    }
}

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        let dc: DataController = DataController.preview
        let alarm: AtcAlarm = dc.alarmItems[0]
        TitleView(dc: dc, selectedObject: alarm)
    }
}
