//
//  TitleView.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 12/3/22.
//

import SwiftUI

struct SectionLinkView: View {
    
    @Binding var activeAtcObject: AtcObject?
    @ObservedObject var dc: DataController
    @ObservedObject var selectedAtcObject: AtcObject

    var body: some View {
        NavigationLink(value: selectedAtcObject) {
            HStack {
                Text($selectedAtcObject.name.wrappedValue ?? "Unknown")
                    .frame(maxWidth: .infinity, alignment: .leading)
                if ($selectedAtcObject.uniqueId.wrappedValue == activeAtcObject?.uniqueId) {
                    if ($selectedAtcObject.state.wrappedValue == ClockState.ACTIVE.rawValue) {
                        Button(
                            action: {
                                dc.setManagerState(atcObject: selectedAtcObject, newState: ClockState.STOPPED)
                            }){ Label("", systemImage: "pause.circle")
                                    .labelStyle(IconOnlyLabelStyle())
                                    .foregroundColor(Color(.white))
                            }
                            .buttonStyle(PlainButtonStyle())
                    } else if ($selectedAtcObject.state.wrappedValue == ClockState.PAUSED.rawValue || $selectedAtcObject.state.wrappedValue == ClockState.STOPPED.rawValue) {
                        Button(
                            action: {
                                dc.setManagerState(atcObject: selectedAtcObject, newState: ClockState.ACTIVE)
                            }){ Label("", systemImage: "play.circle")
                                    .labelStyle(IconOnlyLabelStyle())
                                    .foregroundColor(Color(.white))
                            }
                            .buttonStyle(PlainButtonStyle())
                    }
                    Button(
                        action: {
                            dc.deleteManagedObject(atcObject: selectedAtcObject)
                            self.activeAtcObject = nil
                        }){
                            Label("", systemImage: "minus.circle.fill")
                                .labelStyle(IconOnlyLabelStyle())
                                .foregroundColor(Color(.red))
                        }
                        .buttonStyle(PlainButtonStyle())
                }
            }.frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

struct SectionLinkView_Previews: PreviewProvider {
    static var previews: some View {
        let dc: DataController = DataController.preview
        let alarm: AtcAlarm = dc.alarmItems[0]
        SectionLinkView(activeAtcObject: .constant(alarm), dc: dc, selectedAtcObject: alarm)
    }
}
