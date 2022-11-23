//
//  AlarmMenuView.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/23/22.
//

import SwiftUI

struct AlarmMenuView: View {
    
    @Binding var alarmObject: AtcObject?
    
    var body: some View {
        Text("Menu")
    }
}

struct AlarmMenuView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmMenuView(alarmObject: .constant(AtcAlarm()))
    }
}
