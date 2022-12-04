//
//  AlarmMenuView.swift
//  Around The Clock$
//
//  Created by Ryan Angelo on 11/23/22.
//

import SwiftUI

struct TimerStatusView: View  {
    
    @ObservedObject var dc: DataController
    @ObservedObject var selectedManager: TimerManager
        
    init(dc: DataController, uid: UUID) {
        self.dc = dc
        self.selectedManager = dc.getManager(uniqueIdentifier: uid) as! TimerManager
    }
    
    var body: some View {
        Text(selectedManager.clockStatus.displayValue )
            .font(.system(size: 60))
            .background(Color(.clear))
            .padding()
    }
    
}

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        let dc: DataController = DataController.preview
        let timer: AtcTimer = dc.timerItems[0]
        TimerStatusView(dc: dc, uid: timer.uniqueId!)
    }
}
