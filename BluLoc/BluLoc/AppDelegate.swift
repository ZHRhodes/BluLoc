//
//  AppDelegate.swift
//  BluLoc
//
//  Created by Zack Rhodes on 12/3/16.
//  Copyright © 2016 zhrhode2. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

	var window: UIWindow?
	var locationManager: CLLocationManager?
	var lastProximity: CLProximity?
	var beaconList: [CLBeacon] = []

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		let uuidString = "B9407F30-F5F8-466E-AFF9-25556B57FE6D"
		let beaconUUID:NSUUID = NSUUID(uuidString: uuidString)!
		let beaconRegion:CLBeaconRegion = CLBeaconRegion(proximityUUID: beaconUUID as UUID, identifier: "Estimotes")
		
		locationManager = CLLocationManager()
		
		// Might wanna replace this with always authorization
		if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse) {
			locationManager?.requestWhenInUseAuthorization()
		}
		
		locationManager?.delegate = self
		locationManager?.pausesLocationUpdatesAutomatically = false
		locationManager?.startMonitoring(for: beaconRegion)
		locationManager?.startRangingBeacons(in: beaconRegion)
		locationManager?.startUpdatingLocation()
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}

}

extension AppDelegate {
	@objc(locationManager:didRangeBeacons:inRegion:) func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
		beaconList = beacons
		NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "reloadBeacons")))
	}
	
	func locationManager(_ manager: CLLocationManager,
	                     didEnterRegion region: CLRegion) {
		manager.startRangingBeacons(in: region as! CLBeaconRegion)
		manager.startUpdatingLocation()
		
		print("You entered the region")
	}
	
	func locationManager(_ manager: CLLocationManager,
	                     didExitRegion region: CLRegion) {
		manager.stopRangingBeacons(in: region as! CLBeaconRegion)
		manager.stopUpdatingLocation()
		
		print("You exited the region")
	}

}

