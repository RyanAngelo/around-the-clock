//
//  AlarmConfigView.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/22/22.
//

import SwiftUI

struct StopwatchConfigView: View {
    
    @ObservedObject var selectedManager: StopwatchManager
    
    var body: some View {
        HStack {
            if (selectedManager.managedObject.state != ClockState.ACTIVE.rawValue) {
                Button(action: start) {
                    Text("Start")
                        .padding()
                        .frame(width: 75, height: 30, alignment: .center)
                        .background(RoundedRectangle(cornerRadius: 8)
                            .fill(Color.green))
                        .font(.system(.title3))
                }.buttonStyle(PlainButtonStyle())
            } else {
                Button(role: .cancel, action: pause) {
                    Text("Stop")
                        .padding()
                        .frame(width: 75, height: 30, alignment: .center)
                        .background(RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red))
                        .font(.system(.title3))
                }.buttonStyle(PlainButtonStyle())
            }
            if (selectedManager.managedObject.state != ClockState.ACTIVE
                .rawValue) {
                Button(action: reset) {
                    Text("Reset")
                        .padding()
                        .frame(width: 75, height: 30, alignment: .center)
                        .background(RoundedRectangle(cornerRadius: 8)
                            .fill(Color.accentColor))
                        .font(.system(.title3))
                }.buttonStyle(PlainButtonStyle())
            } else {
                Button(action: addLap) {
                    Text("Lap")
                        .padding()
                        .frame(width: 75, height: 30, alignment: .center)
                        .background(RoundedRectangle(cornerRadius: 8)
                            .fill(Color.accentColor))
                        .font(.system(.title3))
                }.buttonStyle(PlainButtonStyle())
            }
            
        }
        .padding()
        
    }
    
    func addLap() {
        selectedManager.addLap()
    }
    
    func start() {
        selectedManager.setManagedObjectState(newState: ClockState.ACTIVE)
    }
    
    func pause() {
        selectedManager.setManagedObjectState(newState: ClockState.PAUSED)
    }
    
    func reset() {
        selectedManager.reset()
    }
    
}

struct StopwatchConfigView_Previews: PreviewProvider {
    static var previews: some View {
        let dc: DataController = DataController.preview
        let manager: StopwatchManager = dc.getManager(uniqueIdentifier: dc.stopwatchItems[0].uniqueId!) as! StopwatchManager
        StopwatchConfigView(selectedManager: manager)
    }
}
