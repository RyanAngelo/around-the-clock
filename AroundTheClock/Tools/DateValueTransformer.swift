//
//  DateValueTransformer.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 10/17/17.
//  Copyright © 2018 Ryan Angelo. All rights reserved.
//

import Foundation

@objc (DateValueTransformer) class DateValueTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass { //What do I transform
        return NSString.self
    }
    
    override class func allowsReverseTransformation() -> Bool { //Can I transform back?
        return false
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd h:mm:ss a"
        return dateFormatter.string(for: (value as! Date))
    }
    

}
