//
//  StateValueTransformer.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 12/29/17.
//  Copyright © 2018 Ryan Angelo. All rights reserved.
//

import Foundation
import Cocoa

@objc (StateValueTransformer) class StateValueTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass { //What do I transform
        return NSString.self
    }
    
    override class func allowsReverseTransformation() -> Bool { //Can I transform back?
        return false
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        if((value as! String) == "paused"){
            return NSImage(named: #imageLiteral(resourceName: "paused").name()!)
        }
        if((value as! String) == "off"){
            return NSImage(named: #imageLiteral(resourceName: "notrunning").name()!)
        }
        if((value as! String) == "on" || (value as! String) == "activated"){
            return NSImage(named: #imageLiteral(resourceName: "on").name()!)
        }
        else{
            return NSImage(named: #imageLiteral(resourceName: "notrunning").name()!)
        }
    }
    
}

extension NSValueTransformerName {
    static let stateValueTransformerName = NSValueTransformerName(rawValue: "stateValueTransformer")
}
