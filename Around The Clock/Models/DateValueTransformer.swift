//
//  ValueTransformer.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 10/17/17.
//  Copyright © 2017 Ryan Angelo. All rights reserved.
//

import Cocoa

class DateValueTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass { //What do I transform
        return NSString.self
    }
    
    override class func allowsReverseTransformation() -> Bool { //Can I transform back?
        return false
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let type = value as? AnyClass else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd yyyy"
        return dateFormatter.string(for: type)
    }
    

}
