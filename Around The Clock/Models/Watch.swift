//
//  Around_The_Clock.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 12/14/14.
//  Copyright (c) 2017 Ryan Angelo. All rights reserved.
//

import Foundation
import CoreData

class Watch: NSManagedObject {

    @NSManaged var elapsedtime: String
    @NSManaged var watchstate: String
    @NSManaged var uid: String
    @NSManaged var starttime: Date
    @NSManaged var pausetime: Date
    @NSManaged var name: String
    @NSManaged var splits: String

}
