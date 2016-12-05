//
//  Float+RoundToPlaces.swift
//  BluLoc
//
//  Created by Zack Rhodes on 12/4/16.
//  Copyright © 2016 zhrhode2. All rights reserved.
//

import Foundation

extension Float {
	/// Rounds the double to decimal places value
	func roundToPlaces(places:Int) -> Float {
		let divisor = pow(10.0, Float(places))
		return (self * divisor).rounded() / divisor
	}
}
