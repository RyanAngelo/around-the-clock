//
//  AlarmMenuView.swift
//  Around The Clock$
//
//  Created by Ryan Angelo on 11/23/22.
//

import SwiftUI

struct StatusView: View  {
    
    @ObservedObject var dc: DataController
    @ObservedObject var selectedManager: AlarmManager
        
    init(dc: DataController, uid: UUID) {
        self.dc = dc
        self.selectedManager = dc.getAlarmManager(uniqueIdentifier: uid)
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
        let alarm: AtcAlarm = dc.alarmItems[0]
        StatusView(dc: dc, uid: alarm.uniqueId!)
    }
}
