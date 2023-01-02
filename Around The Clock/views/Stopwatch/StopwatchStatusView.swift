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
                .font(.system(size: 65).monospacedDigit())
                .background(Color(.clear))
            StopwatchLapView(selectedManager: selectedManager)
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
