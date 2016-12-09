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
	private var proxLabel: UILabel!
	
	init(_ location: Location){
		super.init(frame: CGRect(x: location.immPt.x, y: location.immPt.y, width: 100, height: 100))
		proxLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 25))
		proxLabel.backgroundColor = UIColor.gray
		addSubview(proxLabel)
		self.location = location
		self.setBackgroundImage(UIImage(named: "beacon1.png"), for: .normal)
	}
	
	func setLabel(prox:String){
		proxLabel.text = prox
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
