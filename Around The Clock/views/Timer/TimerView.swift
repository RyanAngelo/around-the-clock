//
//  AlarmView.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 1/2/23.
//

import SwiftUI

struct TimerView: View {
    
    @ObservedObject var selectedManager: TimerManager
    @ObservedObject var atcObject: AtcObject
    @ObservedObject var dc: DataController

    init(dc: DataController, atcObject: AtcObject) {
        self.atcObject = atcObject
        self.dc = dc
        self.selectedManager = dc.getManager(uniqueIdentifier: atcObject.uniqueId!) as! TimerManager
    }

    var body: some View {
        HStack {
            TimerStatusView(selectedManager: self.selectedManager)
            TimerConfigView(selectedManager: self.selectedManager)
        }.padding()
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        let dc: DataController = DataController.preview
        let timerObject = dc.timerItems[0]
        TimerView(dc:dc, atcObject: timerObject)
    }
}
