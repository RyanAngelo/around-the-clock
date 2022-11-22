//
//  TimeWindowView.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/22/22.
//

import SwiftUI

struct TimeWindowView: View {
    
    //HH:mm:ss
    @Binding var timeRemaining: String
    
    var body: some View {
        VStack {
            Text(timeRemaining)
                .font(.largeTitle)
        }
    }
}

struct TimeWindowView_Previews: PreviewProvider {
    static var previews: some View {
        let time: String = "00:00:00"
        TimeWindowView(timeRemaining: .constant(time))
    }
}
