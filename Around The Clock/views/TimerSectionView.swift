//
//  AlarmSectionListing.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 1/2/23.
//

import SwiftUI

struct TimerSectionView: View {
    
    //Environment passed from parent
    @ObservedObject var dc: DataController
    @Binding var atcObject: AtcObject?

    var body: some View {
        Section(header: Text("Timers")) {
            ForEach(dc.timerItems) { timer in
                NavigationLink(value: timer) {
                    HStack {
                        Text(timer.name ?? "Unknown Timer")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if (timer.isEqual(to: atcObject)) {
                            Button(
                            action: {
                                self.atcObject = nil
                                dc.deleteManagedObject(atcObject: timer)
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

struct StopwatchSectionListing_Previews: PreviewProvider {
    static var previews: some View {
        let dc: DataController = DataController.preview
        TimerSectionView(dc: dc, atcObject: .constant(dc.timerItems[0]))
    }
}
