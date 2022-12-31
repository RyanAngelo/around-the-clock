//
//  StatusWheelView.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 12/31/22.
//

import SwiftUI

struct StatusWheelView: View {

    @Binding var clockStatus: ClockStatus
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.gray.opacity(0.75),
                    lineWidth: 10
                )
            Circle()
                .trim(from: 0, to: $clockStatus.percentComplete.wrappedValue ?? 0.0)
                .stroke(
                    Color.green,
                    style: StrokeStyle(
                        lineWidth: 10,
                        lineCap: .round
                    )
                )
                //start the status from the top
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: $clockStatus.percentComplete.wrappedValue ?? 0.0)
        }
    }
}

struct StatusWheelView_Previews: PreviewProvider {
    static var previews: some View {
        let clockStatus: ClockStatus = ClockStatus(displayValue: "PREVIEW", activated: false, associatedObject: UUID(), percentComplete: 0.1)
        StatusWheelView(clockStatus: .constant(clockStatus))
    }
}
