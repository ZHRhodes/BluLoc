//
//  MoreViewController.swift
//  BluLoc
//
//  Created by Zack Rhodes on 12/4/16.
//  Copyright © 2016 zhrhode2. All rights reserved.
//

import Foundation
import UIKit

class MoreViewController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
	
	@IBOutlet var pickerView: UIPickerView!
	var pickerDataSource: [String] = []

	override func viewDidLoad() {
		for location in Locations.allLocations {
			pickerDataSource.append(location.rawValue)
		}
	}
	
	@IBAction func setLocationButtonPress(_ sender: AnyObject) {
		NotificationCenter.default.post(Notification(name: Notification.Name(rawValue:"updateUserLocation"), object: self, userInfo: ["location":pickerDataSource[pickerView.selectedRow(inComponent: 0)]]))
	}
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return pickerDataSource.count;
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return pickerDataSource[row]
	}
}
