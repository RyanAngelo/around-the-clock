//
//  Alarm.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 11/4/14.
//  Copyright (c) 2018 Ryan Angelo. All rights reserved.
//

import Foundation
import CoreData

class Alarm: NSManagedObject {

    @NSManaged dynamic var alarmtime: Date
    @NSManaged dynamic var alarmstate: String
    @NSManaged dynamic var name: String
    @NSManaged dynamic var uid: String
    @NSManaged dynamic var audio: String
    
    //We always want the alarm to be for a future time. So this checks to make sure that the alarm is
    //being set such that when the user starts the alarm, the alarm is always for the next time that time
    //is applicable. This decides whether the alarm should be today or tomorrow.
    func changeDay() -> (){
        
        let timeinterval = self.alarmtime.timeIntervalSinceNow
        let alarmtime: Date = self.alarmtime as Date
        let oneday: TimeInterval = TimeInterval(86400)
        var daystosubtract = oneday
        if timeinterval.sign == .minus{
            if abs(timeinterval)/oneday > 1{
                daystosubtract=(abs(timeinterval)/oneday)*oneday
            }
            let new_date: Date=alarmtime.addingTimeInterval(daystosubtract) //add 24 hours to the alarm
            self.alarmtime=new_date
        }
        if(timeinterval >= oneday){ //If you are more than one day ahead in the future...
            if timeinterval/oneday >= 2{
                daystosubtract=(timeinterval/oneday)-(timeinterval.truncatingRemainder(dividingBy: oneday))
                daystosubtract=daystosubtract*oneday
            }
            let new_date: Date=alarmtime.addingTimeInterval(-daystosubtract) //subtract amt
            self.alarmtime=new_date
        }
    }
    
    func setState(state: String){
        alarmstate = state
    }
}
