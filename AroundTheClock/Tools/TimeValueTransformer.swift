//
//  StateValueTransformer.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 12/29/17.
//  Copyright © 2018 Ryan Angelo. All rights reserved.
//
import Foundation
import Cocoa

@objc (TimeValueTransformer) class TimeValueTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass { //What do I transform
        return NSNumber.self
    }
    
    override class func allowsReverseTransformation() -> Bool { //Can I transform back?
        return false
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        if ( value as! Int > 0 ) {
            let strFormat = calculateDisplayTime(value as! Int)
            let strHours=strFormat.strHours as String
            let strMinutes=strFormat.strMinutes as String
            let strSeconds=strFormat.strSeconds as String
            return "\(strHours):\(strMinutes):\(strSeconds)"
        } else {
            return "00:00:00";
        }
    }
    
    
    func calculateDisplayTime(_ ptimeinterval: Int) -> (strHours: NSString, strMinutes: NSString, strSeconds: NSString){
        var hours=UInt16(0)
        var minutes=UInt16(0)
        var seconds=UInt16(0)
        var timeinterval: Int = ptimeinterval
        if (timeinterval == 0 || timeinterval < 0) {
            hours=0
            minutes=0
            seconds=0
        }else{
            hours=UInt16((timeinterval/60)/60)
            timeinterval-=Int(hours)*60*60
            minutes=UInt16(timeinterval/60)
            timeinterval-=Int(minutes)*60
            seconds=UInt16(timeinterval)
        }
        let strHours=hours > 9 ? String(hours):"0"+String(hours)
        let strMinutes=minutes > 9 ? String(minutes):"0"+String(minutes)
        let strSeconds=seconds > 9 ? String(seconds):"0"+String(seconds)
        
        return (strHours as NSString, strMinutes as NSString, strSeconds as NSString)
    }
    
}

extension NSValueTransformerName {
    static let timeValueTransformer = NSValueTransformerName(rawValue: "timeValueTransformer")
}
