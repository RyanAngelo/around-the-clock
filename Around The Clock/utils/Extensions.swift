//
//  Extensions.swift
//  Around The Clock
//
//  Created by Ryan Angelo on 12/24/22.
//

import Foundation

extension Date {

    func startOfMinute() -> Date?
    {
        let calendar = Calendar.current

        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)

        components.second = 0

        return calendar.date(from: components)
    }

}
