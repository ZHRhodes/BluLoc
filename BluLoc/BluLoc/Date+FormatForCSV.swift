//
//  Date+FormatForCSV.swift
//  BluLoc
//
//  Created by Zack Rhodes on 12/8/16.
//  Copyright © 2016 zhrhode2. All rights reserved.
//

import Foundation

extension Date {
	mutating func formatDateForCSV()->String{
		
		var calendar = Calendar.current
		let unitFlags = Set<Calendar.Component>([.year, .month, .day, .hour, .minute, .second])
		calendar.timeZone = TimeZone(identifier: "CST")!
		let components = calendar.dateComponents(unitFlags, from: self)
		
		let formatter = NumberFormatter()
		formatter.minimumIntegerDigits = 2
		let month = formatter.string(from: NSNumber(value: components.month!))!
		let day = formatter.string(from: NSNumber(value: components.day!))!
		let year = formatter.string(from: NSNumber(value: components.year! - 2000))!
		let hour = formatter.string(from: NSNumber(value: components.hour!))!
		let minute = formatter.string(from: NSNumber(value: components.minute!))!
		let second = formatter.string(from: NSNumber(value: components.second!))!
		
		return "<\(month)-\(day)-\(year)><\(hour)_\(minute)_\(second)>"
		
	}
}
