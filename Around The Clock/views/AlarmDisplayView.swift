//
//  AlarmDisplayView.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/23/22.
//

import SwiftUI

struct AlarmDisplayView: View {
    
    @Binding var alarmObject: AtcObject?

    var body: some View {
        /*TextField("Placeholder",
                  text: $alarmObject.name)*/
        Text((alarmObject?.name)!)
    }
}

struct AlarmDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmDisplayView(alarmObject: .constant(AtcAlarm()))
    }
}
