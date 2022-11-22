//
//  ClockObjectProtocol.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/22/22.
//

import Foundation

protocol ClockObjectProtocol {
    func start()
    func stop()
    func updateData()
    func getManagedIdentifier() -> ObjectIdentifier
}
