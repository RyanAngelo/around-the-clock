//
//  ActiveAlerts.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 12/24/22.
//

import Foundation

struct ActiveAlert: Identifiable {
    var id = UUID()
    var associatedObject: AtcObject
}
