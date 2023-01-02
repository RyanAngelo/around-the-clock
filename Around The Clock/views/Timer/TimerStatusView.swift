//
//  AlarmMenuView.swift
//  Around The Clock$
//
//  Created by Ryan Angelo on 11/23/22.
//

import SwiftUI

struct TimerStatusView: View  {
    
    @ObservedObject var selectedManager: TimerManager

    var body: some View {
        ZStack {
            StatusWheelView(clockStatus: $selectedManager.clockStatus).scaledToFit()
            Text(selectedManager.clockStatus.displayValue)
                .font(.system(size: 60).monospacedDigit())
                .background(Color(.clear))
        }
    }
}

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        let dc: DataController = DataController.preview
        let manager: TimerManager = dc.getManager(uniqueIdentifier: dc.timerItems[0].uniqueId!) as! TimerManager
        TimerStatusView(selectedManager: manager)
    }
}
