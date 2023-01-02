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
                NavigationLink(value: alarm) {
                    HStack {
                        Text(alarm.name ?? "Unknown Alarm")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if (alarm.isEqual(to: atcObject)) {
                            Button(
                            action: {
                                self.atcObject = nil
                                dc.deleteManagedObject(atcObject: alarm)
                            }){
                            Label("", systemImage: "minus.circle")
                                .labelStyle(IconOnlyLabelStyle())
                                .foregroundColor(Color(.white))
                            }
                            .buttonStyle(PlainButtonStyle())
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                }
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
