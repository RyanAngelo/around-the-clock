//
//  AlarmSectionListing.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 1/2/23.
//

import SwiftUI

struct AlarmSectionView: View {
    
    //Environment passed from parent
    @ObservedObject var dc: DataController
    @Binding var atcObject: AtcObject?

    var body: some View {
        Section(header: Text("Alarms")) {
            ForEach(dc.alarmItems) { alarm in
                SectionLinkView(activeAtcObject: $atcObject, dc: dc, selectedAtcObject: alarm)
            }
        }
    }
}

struct AlarmSectionListing_Previews: PreviewProvider {
    static var previews: some View {
        let dc: DataController = DataController.preview
        AlarmSectionView(dc: dc, atcObject: .constant(dc.alarmItems[0]))
    }
}
