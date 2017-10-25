//
//  Alarm.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/4/14.
//  Copyright (c) 2016 Ryan Angelo. All rights reserved.
//

import Foundation
import CoreData

class Alarm: NSManagedObject {

    @NSManaged dynamic var alarmtime: Date
    @NSManaged dynamic var alarmstate: String
    @NSManaged dynamic var name: String
    @NSManaged dynamic var uid: String
    @NSManaged dynamic var audio: String
}
