//
//  UserDot.swift
//  BluLoc
//
//  Created by Zack Rhodes on 12/8/16.
//  Copyright © 2016 zhrhode2. All rights reserved.
//

import Foundation
import UIKit

class UserDot : UIButton {
	let stepLength:Double = 0.679958
	let mapScaleFactor = 35.0
	
	var coords: CGPoint {
		return CGPoint(x: self.frame.minX, y: self.frame.minY)
	}
	
	init(_ location: Location, _ map: UIImageView){
		super.init(frame: CGRect(x: location.immPt.x, y: location.immPt.y, width: 100, height: 100))
		self.setBackgroundImage(UIImage(named: "userDot.png"), for: .normal)
		map.addSubview(self)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setUserLocation(_ loc: Locations){
		setUserLocation(x: loc.location().immPt.x, y: loc.location().immPt.y)
	}
	
	func setUserLocation(loc: (x:Int, y:Int)){
		setUserLocation(x: loc.x, y: loc.y)
	}
	
	func setUserLocation(x: Int, y: Int){
		self.frame = CGRect(x: CGFloat(x), y: CGFloat(y), width: self.frame.width, height: self.frame.height)
	}
	
	func updateUserLocation(_ deltaX: Double, _ deltaY: Double){
		let c = coords
		let newX = Double(c.x) + deltaX
		let newY = Double(c.y) + deltaY
		setUserLocation(x: Int(newX), y: Int(newY))
	}
	
	func takeStep(towards: Location, yaw: Double, accuracy: Double){
		var accuracyMultiplier = 1.0
		if accuracy < 1 {
			accuracyMultiplier = 5
		}else{
			if accuracy < 5{
				accuracyMultiplier = 3
			}else{
				accuracyMultiplier = 1.8
			}
		}
		let tAngle = angle(to: CGPoint(x: towards.immPt.x, y: towards.immPt.y))
		let posYaw = yaw//toPosRadians(rads: yaw)
		let angleToMove = movingAway(angle1: tAngle, angle2: posYaw) ? posYaw : tAngle
		takeStep(angle: angleToMove, customStepLength: stepLength * 3)//splitAngles(angle1: tAngle, angle2: posYaw), customStepLength: stepLength * 3)//CGFloat(posYaw)))
	}
	
	func toPosRadians(rads: Double)->Double{
		if (rads < 0) {
			let ret = (2*M_PI) + rads
			return ret
		}else{
			return rads
		}
	}
	
	func takeStep(angle: Double, customStepLength : Double?){
		let slength = customStepLength == nil ? stepLength : customStepLength
		let deltaX = mapScaleFactor * slength! * cos(angle)
		let deltaY = -mapScaleFactor * slength! * sin(angle)
		self.updateUserLocation(deltaX, deltaY)
	}
	
	func distance(from: CGPoint)->Int{
		let c = coords
		//print(c, from)
		return Int(sqrt(pow(c.x - from.x, 2) + pow(c.y - from.y, 2)))
	}
	
	func angle(to: CGPoint)->Double{
		let c = coords
		let tan = atan2(c.y - to.y, to.x - c.x)
		return Double(tan)//toPosRadians(rads: Double(tan))
	}
	
	func splitAngles(angle1: Double, angle2: Double)->Double{
		let split = Double((4*angle1 + angle2) / 5)
		//print("angle1 = \(angle1), angle2 = \(angle2), split = \(split)")
		return split
	}
	
	func movingAway(angle1: Double, angle2: Double)->Bool{
		var ret = true
		if(angle2 >= 0 && angle1 > 0){
			ret = false
		}else if (fabs(angle2) >= M_PI/2 && fabs(angle1) > M_PI/2){
			ret = false
		}else if (angle2 <= 0 && angle1 < 0){
			ret = false
		}else if (fabs(angle2) < M_PI/2 && fabs(angle1) < M_PI/2){
			ret = false
		}
		//print(angle1, angle2, ret)
		return ret
	}
	
}
