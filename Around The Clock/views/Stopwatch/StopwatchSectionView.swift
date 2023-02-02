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
                SectionLinkView(activeAtcObject: $atcObject, dc: dc, selectedAtcObject: stopwatch)
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
