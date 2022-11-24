//
//  AlarmMenuView.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/23/22.
//

import SwiftUI

struct AlarmMenuView: View {
    
    @ObservedObject var dataController: DataController
    
    var body: some View {
        Text("Menu")
    }
}

struct AlarmMenuView_Previews: PreviewProvider {
    static var previews: some View {
        let dc: DataController = DataController()
        AlarmMenuView(dataController: dc)
    }
}
