//
//  TimeWindowView.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/22/22.
//

import SwiftUI

struct ConfigView: View {
    
    @ObservedObject var dc: DataController
    @ObservedObject var selectedObject: AtcObject
    
    var body: some View {
        VStack {
        }
    }
}

struct ConfigView_Previews: PreviewProvider {
    static var previews: some View {
        let dc: DataController = DataController.preview
        let alarm: AtcAlarm = dc.alarmItems[0]
        ConfigView(dc: dc, selectedObject: alarm)
    }
}
