//
//  StopwatchLapView.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 1/2/23.
//

import SwiftUI

struct StopwatchLapView: View {
    
    @ObservedObject var selectedManager: StopwatchManager

    var body: some View {
        Table(selectedManager.getLaps()) {
            TableColumn("Lap Time") { lap in
                Text(selectedManager.stringFromTime(interval: lap.timeInterval))
                    .foregroundColor(lap.fastest ? Color.green : lap.slowest ? Color.red : Color.primary)
                    
            }
        }
    }
}

struct StopwatchLapView_Previews: PreviewProvider {
    static var previews: some View {
        let dc: DataController = DataController.preview
        let manager: StopwatchManager = dc.getManager(uniqueIdentifier: dc.stopwatchItems[0].uniqueId!) as! StopwatchManager
        StopwatchLapView(selectedManager: manager)
    }
}
