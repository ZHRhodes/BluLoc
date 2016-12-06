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
	let stepLength:Double = 0.679958
	let mapScaleFactor = 35.0
	
	var scrollView: UIScrollView!
	var floorplanView: UIImageView!
	
	var allBeacons: [MapBeacon] = []
	var beacons: [CLBeacon] = []
	
	var userDot: UIButton!
	
	let appDelegate = UIApplication.shared.delegate as! AppDelegate
	
	var beaconManager: BeaconManager!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		beaconManager = BeaconManager(totalBeacons: 10)
		suscribeToNotification()
		setupView()
		motionManager.deviceMotionUpdateInterval = 0.1
		motionManager.startDeviceMotionUpdates()
		motionManager.startAccelerometerUpdates()
		motionManager.startGyroUpdates()

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
		addUserToMap(withLocation: Locations.room_2017.location())
		scrollView.addSubview(floorplanView)
		view.addSubview(scrollView)
	}
	
	func addBeaconsToMap(withLocationSet beaconLocations: [Locations]){
		for location in beaconLocations {
			let newBeacon = MapBeacon(location.location())
			floorplanView.addSubview(newBeacon)
		}
	}
	
	func reloadBeaconData(_ newBeacons: [CLBeacon]){
		beacons = appDelegate.beaconList
		var beaconData: [(Int, Int)] = []
		for b in beacons {
			if let id = Locations.getId(major: Int(b.major)){
				beaconData.append((b.rssi, id))
			}
		}
		
		if let newLocation = beaconManager.updateState(bData: beaconData){
			setUserLocation(location: newLocation)
			print("resetting to new location \(newLocation)")
		}
		print("---- PRINTING NEW BEACON DATA ----")
		for beacon in beacons{
			switch beacon.proximity {
			case CLProximity.far:
				print("major = \(beacon.major) minor = \(beacon.rssi) is Far")
			case CLProximity.near:
				print("major = \(beacon.major) minor = \(beacon.rssi) is Near")
			case CLProximity.immediate:
				print("major = \(beacon.major) minor = \(beacon.rssi) is Immediate")
			case CLProximity.unknown:
				print("major = \(beacon.major) minor = \(beacon.rssi) is Unknown")
			}
			
		}
	}
	
	func addUserToMap(withLocation location: Location){
		userDot = UIButton(frame: CGRect(x: location.x, y: location.y, width: 100, height: 100))
		userDot.setBackgroundImage(UIImage(named: "userDot.png"), for: .normal)
		floorplanView.addSubview(userDot)
	}
	
	func moveUserLocation(_ notification : NSNotification){
		motionManager.stopDeviceMotionUpdates()
		motionManager.startDeviceMotionUpdates()
		if let dict = notification.userInfo{
			if let loc = Locations(rawValue: dict["location"] as! String){
				setUserLocation(x: loc.location().x, y: loc.location().y)
			}
		}
	}
	
	func setUserLocation(location: Locations){
		setUserLocation(x: location.location().x, y: location.location().y)
	}
	
	func setUserLocation(x: Int, y: Int){
		userDot.frame = CGRect(x: CGFloat(x), y: CGFloat(y), width: userDot.frame.width, height: userDot.frame.height)
	}
	
	func updateUserLocation(_ deltaX: Double, _ deltaY: Double){
		let newX = Double(userDot.frame.minX) + deltaX
		let newY = Double(userDot.frame.minY) + deltaY
		setUserLocation(x: Int(newX), y: Int(newY))
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
		let attitude = motionManager.deviceMotion?.attitude
		let deltaX = mapScaleFactor * stepLength * cos((attitude?.yaw)!)
		let deltaY = -mapScaleFactor * stepLength * sin((attitude?.yaw)!)
		updateUserLocation(deltaX, deltaY)
	}
	
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return floorplanView
	}

}

