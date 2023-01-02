//
//  AlarmSectionListing.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 1/2/23.
//

import SwiftUI

struct StopwatchSectionView: View {
    
    //Environment passed from parent
    @ObservedObject var dc: DataController
    @Binding var atcObject: AtcObject?

    var body: some View {
        Section(header: Text("Stopwatches")) {
            ForEach(dc.stopwatchItems) { stopwatch in
                NavigationLink(value: stopwatch) {
                    HStack {
                        Text(stopwatch.name ?? "Unknown Stopwatch")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if (stopwatch.isEqual(to: atcObject)) {
                            Button(
                            action: {
                                self.atcObject = nil
                                dc.deleteManagedObject(atcObject: stopwatch)
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

struct TimerSectionListing_Previews: PreviewProvider {
    static var previews: some View {
        let dc: DataController = DataController.preview
        TimerSectionView(dc: dc, atcObject: .constant(dc.timerItems[0]))
    }
}
