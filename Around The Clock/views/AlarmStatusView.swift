//
//  AlarmMenuView.swift
//  Around The Clock$
//
//  Created by Ryan Angelo on 11/23/22.
//

import SwiftUI

struct AlarmStatusView: View  {
    
    @ObservedObject var selectedManager: AlarmManager
    
    var body: some View {
        Text(selectedManager.clockStatus.displayValue )
            .font(.system(size: 60).monospacedDigit())
            .background(Color(.clear))
            .padding()
    }
    
}

struct AlarmStatusView_Previews: PreviewProvider {
    static var previews: some View {
        let dc: DataController = DataController.preview
        let manager: AlarmManager = dc.getManager(uniqueIdentifier: dc.alarmItems[0].uniqueId!) as! AlarmManager
        AlarmStatusView(selectedManager: manager)
    }
}
