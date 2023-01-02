//
//  AlarmView.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 1/2/23.
//

import SwiftUI

struct StopwatchView: View {
    
    @ObservedObject var selectedManager: StopwatchManager
    @ObservedObject var atcObject: AtcObject
    @ObservedObject var dc: DataController

    init(dc: DataController, atcObject: AtcObject) {
        self.atcObject = atcObject
        self.dc = dc
        self.selectedManager = dc.getManager(uniqueIdentifier: atcObject.uniqueId!) as! StopwatchManager
    }

    var body: some View {
        VStack {
            StopwatchStatusView(selectedManager: self.selectedManager)
            Spacer()
            StopwatchConfigView(selectedManager: self.selectedManager)
        }.padding()
    }
}

struct StopwatchView_Previews: PreviewProvider {
    static var previews: some View {
        let dc: DataController = DataController.preview
        let stopwatchObject = dc.stopwatchItems[0]
        StopwatchView(dc:dc, atcObject: stopwatchObject)
    }
}
