//
//  ViewController.swift
//  BluLoc
//
//  Created by Zack Rhodes on 12/3/16.
//  Copyright © 2016 zhrhode2. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion


class MapViewController: UIViewController, UIScrollViewDelegate {
	
	let motionManager = CMMotionManager()
	var totalRotation:Float = 0.0
	var accelMagData: [Double] = [Double]()
	var gyroMagData: [Double] = [Double]()

	
	var scrollView: UIScrollView!
	var floorplanView: UIImageView!
	
	var mapBeacons: [MapBeacon] = []
	var beacons: [CLBeacon] = []
	
	var userDot: UserDot!
	
	let appDelegate = UIApplication.shared.delegate as! AppDelegate
	
	var beaconManager: BeaconManager!
	
	var locationCSV: LocationCSV?
	
	var yaw: Double {
		get{
			if let attitude = motionManager.deviceMotion?.attitude{
				return attitude.yaw
			}else{
				return 0
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		beaconManager = BeaconManager(totalBeacons: 10)
		suscribeToNotification()
		setupView()
		motionManager.deviceMotionUpdateInterval = 0.1
		motionManager.startDeviceMotionUpdates()
		motionManager.startAccelerometerUpdates()
		motionManager.startGyroUpdates()

		locationCSV = LocationCSV()
		
		_ = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateSteps), userInfo: nil, repeats: true)
	}
	
	func suscribeToNotification(){
		NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.reloadBeaconData(_:)), name: NSNotification.Name(rawValue: "reloadBeacons"), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.moveUserLocation(_:)), name: NSNotification.Name(rawValue: "updateUserLocation"), object: nil)
	}
	
	func setupView(){
		floorplanView = UIImageView(image: UIImage(named: "ECEBLevel2.png"))
		
		scrollView = UIScrollView(frame: view.bounds)
		scrollView.backgroundColor = UIColor.white
		scrollView.contentSize = floorplanView.bounds.size
		scrollView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
		scrollView.contentOffset = CGPoint(x: 100, y: 1200)
		
		scrollView.delegate = self
		scrollView.minimumZoomScale = 0.2
		scrollView.maximumZoomScale = 1.0
		scrollView.zoomScale = 0.3
		
		addBeaconsToMap(withLocationSet: Locations.allLocations)
		userDot = UserDot(Locations.room_2017.location(), floorplanView)
		scrollView.addSubview(floorplanView)
		view.addSubview(scrollView)
	}
	
	func addBeaconsToMap(withLocationSet beaconLocations: [Locations]){
		for location in beaconLocations {
			let newBeacon = MapBeacon(location.location())
			mapBeacons.append(newBeacon)
			floorplanView.addSubview(newBeacon)
		}
	}
	
	func reloadBeaconData(_ newBeacons: [CLBeacon]){
		beacons = appDelegate.beaconList
		var beaconData: [(Int, Int)] = []
		var rangeData: [(title1:String, name:String,title2:String,(x:Int,y:Int),title3:String,proximity:String,title4:String,rssi:Int,title5:String,accuracy:Double)] = []
		for b in beacons {
			if let id = Locations.getId(major: Int(b.major)){
				beaconData.append((b.rssi, id))
			}
			if let location = Locations.getLocation(id: Locations.getId(major: Int(b.major))){
				if b.proximity == CLProximity.immediate{
					if(b.accuracy < 3){
						userDot.setUserLocation(location)
						print("resetting for immediate!")
					}
				}
				rangeData.append(("Name:",location.rawValue,"(x,y):",(Int(userDot.frame.minX), Int(userDot.frame.minY)),"Proximity:",getProximityString(b.proximity),"RSSI:",b.rssi,"Accuracy",b.accuracy))
				let _ = locationCSV?.appendRow(items: [location.rawValue,String(userDot.distance(from: CGPoint(x: location.location().immPt.x,y: location.location().immPt.y))),String(b.rssi),String(b.accuracy)])
				
				let dotDist = userDot.distance(from: CGPoint(x: location.location().immPt.x, y: location.location().immPt.y))
				for mb in mapBeacons { //this shouldn't be in here?
					if mb.location.id == Locations.getId(major: Int(b.major)){
						mb.setLabel(prox: "\(dotDist) \(getProximityString(b.proximity)) \(String(b.rssi)) \(String(b.accuracy))")
					}
				}
			}
		}
		
		if let newLocation = beaconManager.updateState(bData: beaconData){
			userDot.setUserLocation(loc: newLocation.location().immPt)
			print("resetting to new location \(newLocation)")
		}
		
		//for row in rangeData {
			//print("\(row)\n")
		//}
		
//		print("---- PRINTING NEW BEACON DATA ----")
//		for beacon in beacons{
//			switch beacon.proximity {
//			case CLProximity.far:
//				print("major = \(beacon.major) minor = \(beacon.rssi) is Far")
//			case CLProximity.near:
//				print("major = \(beacon.major) minor = \(beacon.rssi) is Near")
//			case CLProximity.immediate:
//				print("major = \(beacon.major) minor = \(beacon.rssi) is Immediate")
//			case CLProximity.unknown:
//				print("major = \(beacon.major) minor = \(beacon.rssi) is Unknown")
//			}
//			
//		}
		
	}
	
	func getProximityString(_ prox:CLProximity)->String{
		switch(prox){
		case CLProximity.far:
			return "FAR"
		case CLProximity.near:
			return "NEAR"
		case CLProximity.immediate:
			return "IMMEDIATE"
		case CLProximity.unknown:
			return "UNKNOWN"
		}
	}
	
	func moveUserLocation(_ notification : NSNotification){
		motionManager.stopDeviceMotionUpdates()
		motionManager.startDeviceMotionUpdates()
		if let dict = notification.userInfo{
			if let loc = Locations(rawValue: dict["location"] as! String){
				userDot.setUserLocation(loc)
				locationCSV?.exportData()
			}
		}
	}
	
	func updateSteps(){
		if let accelX = motionManager.accelerometerData?.acceleration.x {
			let accelY = motionManager.accelerometerData?.acceleration.y
			let accelZ = motionManager.accelerometerData?.acceleration.z
			if let gyroX = motionManager.gyroData?.rotationRate.x{
				let gyroY = motionManager.gyroData?.rotationRate.y
				let gyroZ = motionManager.gyroData?.rotationRate.z
				addToMagData(accelData: calculateMagnitude(x: accelX, y: accelY!, z: accelZ!), gyroData: calculateMagnitude(x: gyroX, y: gyroY!, z: gyroZ!))
			}
		}
	}
	
	func calculateMagnitude(x: Double, y: Double, z: Double)->Double{
		return sqrt(x*x + y*y + z*z)
	}

	/*Simple step algorithm based on threshold gathered form empirical measurements
	gyro check is to account for when the phone is in the pocket. Swinging legs cause
	much higher accelerometer readings than walking with phone in hand. Only checked
	every 50 readings (0.50 seconds) so that one step isn't counted multiple times */
	func addToMagData(accelData: Double, gyroData: Double){
		accelMagData.append(accelData)
		gyroMagData.append(gyroData)
		if(accelMagData.count==50){
			let maxAccel = accelMagData.max()
			let maxGyro = gyroMagData.max()
			
			if(maxGyro! > 1.8){
				if(maxAccel! > 1.7){
					takeStep()
				}
			}else{
				if(maxAccel! > 1.20){
					takeStep()
				}
			}
			accelMagData.removeAll()
			gyroMagData.removeAll()
		}
	}
	
	func takeStep(){
//		for b in beacons {
//			if let location = Locations.getLocation(id: Locations.getId(major: Int(b.major))){
//				let dotDist = userDot.distance(from: CGPoint(x: location.location().immPt.x, y: location.location().immPt.y))
//				switch b.proximity {
//				case CLProximity.immediate:
//					//setUserLocation(location: location)
//					//print("resetting for immediate!")
//					return
//				case CLProximity.near:
//					if(b.accuracy > 2.4){
//						break
//					}
//					if(dotDist > location.location().radius.R_far){
//						setUserLocation(location: location)
//						return
//					}
//					if dotDist > location.location().radius.R_near {
//						userDot.takeStep(towards: location.location(), yaw: yaw, accuracy: b.accuracy)
//						print("adjusting for near!")
//						return
//					}
//				break
//				case CLProximity.far:
////					if(b.accuracy > 10){
////						break
////					}
////					if dotDist > location.location().radius.R_far {
////						userDot.takeStep(towards: location.location(), yaw: yaw, accuracy: b.accuracy)
////						print("adjusting for near!")
////						return
////					}
//					break
//					
//				case CLProximity.unknown:
//					break
//				}
//			}
//		}
		userDot.takeStep(angle: yaw, customStepLength: nil)
	}
	
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return floorplanView
	}

}

