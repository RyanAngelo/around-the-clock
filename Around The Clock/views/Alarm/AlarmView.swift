//
//  AlarmView.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 1/2/23.
//

import SwiftUI

struct AlarmView: View {
    
    @ObservedObject var selectedManager: AlarmManager
    @ObservedObject var atcObject: AtcObject
    @ObservedObject var dc: DataController

    init(dc: DataController, atcObject: AtcObject) {
        self.atcObject = atcObject
        self.dc = dc
        self.selectedManager = dc.getManager(uniqueIdentifier: atcObject.uniqueId!) as! AlarmManager
    }

    var body: some View {
        VStack {
            AlarmStatusView(selectedManager: self.selectedManager)
            Spacer()
            AlarmConfigView(selectedManager: self.selectedManager)
        }
    }
}

struct AlarmView_Previews: PreviewProvider {
    static var previews: some View {
        let dc: DataController = DataController.preview
        let alarmObject = dc.alarmItems[0]
        AlarmView(dc:dc, atcObject: alarmObject)
    }
}
