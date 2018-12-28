//
//  Countdown.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 12/20/14.
//  Copyright (c) 2018 Ryan Angelo. All rights reserved.
//

import Foundation
import CoreData

class Countdown: NSManagedObject {

    @NSManaged dynamic var countdownstate: String
    @NSManaged dynamic var countdowntime: Int
    @NSManaged dynamic var startcountdowntime: Int
    @NSManaged dynamic var audio: String
    @NSManaged dynamic var name: String
    @NSManaged dynamic var uid: String
    
    func setState(state: String){
        countdownstate = state
    }

}
