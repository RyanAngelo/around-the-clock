//
//  AlarmMenuView.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/23/22.
//

import SwiftUI

struct AlarmMenuView: View {
    
    @ObservedObject var dc: DataController
    @ObservedObject var selectedObject: AtcObject
    
    var body: some View {
        VStack {
            TextField("Name",
                      text: $selectedObject.name.toUnwrapped(defaultValue: ""),
                      onCommit: {
                dc.saveContext() })
            .multilineTextAlignment(.center)
            .font(.largeTitle)
            .padding()
        }
    }
}

struct AlarmMenuView_Previews: PreviewProvider {
    static var previews: some View {
        let dc: DataController = DataController.preview
        let alarm: AtcAlarm = dc.alarmItems[0]
        AlarmMenuView(dc: dc, selectedObject: alarm)
    }
}
