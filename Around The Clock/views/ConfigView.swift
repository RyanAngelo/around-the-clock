//
//  ConfigView.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/22/22.
//

import SwiftUI

struct ConfigView: View {
    
    @ObservedObject var dc: DataController
    @ObservedObject var selectedObject: AtcObject
    
    @State private var date = Date()
    
    var body: some View {
        if selectedObject is AtcAlarm {
            //We know that the selectedObject is an instanceOf AtcAlarm, therefore we force downcast.
            //TOODO: Better way to handle the objects than downcasting?
            AlarmConfigView(dc: dc, selectedObject: selectedObject as! AtcAlarm)
        } else if selectedObject is AtcTimer {
            //TODO: Add TimerConfigView
        }
    }
    
    struct ConfigView_Previews: PreviewProvider {
        static var previews: some View {
            let dc: DataController = DataController.preview
            let alarm: AtcAlarm = dc.alarmItems[0]
            ConfigView(dc: dc, selectedObject: alarm)
        }
    }
    
}
