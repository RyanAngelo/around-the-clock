//
//  AlarmMenuView.swift
//  Around The Clock$
//
//  Created by Ryan Angelo on 11/23/22.
//

import SwiftUI

struct StopwatchStatusView: View  {
    
    @ObservedObject var selectedManager: StopwatchManager
    
    var body: some View {
        VStack {
            Text(selectedManager.clockStatus.displayValue )
                .font(.system(size: 60).monospacedDigit())
                .background(Color(.clear))
                .padding()
            Table(selectedManager.getLaps()) {
                TableColumn("Lap Time") { lap in
                    Text(selectedManager.stringFromTime(interval: lap.timeInterval))
                        .foregroundColor(lap.fastest ? Color.green : lap.slowest ? Color.red : Color.primary)
                        
                }
            }
        }
    }
}

struct StopwatchStatusView_Previews: PreviewProvider {
    static var previews: some View {
        let dc: DataController = DataController.preview
        let manager: StopwatchManager = dc.getManager(uniqueIdentifier: dc.stopwatchItems[0].uniqueId!) as! StopwatchManager
        StopwatchStatusView(selectedManager: manager)
    }
}
