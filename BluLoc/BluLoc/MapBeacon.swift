//
//  Beacon.swift
//  BluLoc
//
//  Created by Zack Rhodes on 12/4/16.
//  Copyright © 2016 zhrhode2. All rights reserved.
//

import Foundation
import UIKit

class MapBeacon : UIButton {
	var location: Location!
	
	init(_ location: Location){
		super.init(frame: CGRect(x: location.x, y: location.y, width: 100, height: 100))
		self.location = location
		self.setBackgroundImage(UIImage(named: "beacon1.png"), for: .normal)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
