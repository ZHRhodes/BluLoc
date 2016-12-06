//
//  BeaconManager.swift
//  BluLoc
//
//  Created by Zack Rhodes on 12/5/16.
//  Copyright © 2016 zhrhode2. All rights reserved.
//

import Foundation
import CoreLocation

enum BeaconState: Int {
	case NOT_FOUND = 0
	case FOUND
	case JUST_LEFT
	case NEIGHBOR
}

class BeaconManager {
	
	var totalBeacons: Int!
	let RSSI_Min = 0 //what is this?
	var beaconRSSI: [(Int,Int,Int,Int,Int)] = []
	var beaconState: [BeaconState] = []
	var needReset: [Int] = []
	
	init(totalBeacons: Int){
		for _ in 0..<totalBeacons{
			self.totalBeacons = totalBeacons
			beaconRSSI.append((RSSI_Min,RSSI_Min,RSSI_Min,RSSI_Min,RSSI_Min))
			beaconState.append(BeaconState.NOT_FOUND)
			needReset.append(0)
		}
	}

	private func updateRSSI(_ bData: [(rssi: Int, id: Int)]){
		for i in 0..<bData.count{
			if bData[i].rssi != 0 {
				beaconRSSI[bData[i].id].4 = beaconRSSI[bData[i].id].3
				beaconRSSI[bData[i].id].3 = beaconRSSI[bData[i].id].2
				beaconRSSI[bData[i].id].2 = beaconRSSI[bData[i].id].1
				beaconRSSI[bData[i].id].1 = beaconRSSI[bData[i].id].0
				beaconRSSI[bData[i].id].0 = bData[i].rssi
			}
		}
	}
	
	func isPeak(RSSI: (Int,Int,Int,Int,Int))->Bool {
		if (RSSI.0 < RSSI.1 && RSSI.1 < RSSI.2 && RSSI.2 > RSSI.3 && RSSI.3 > RSSI.4){
			return true;
		}else{
			return false;
		}
	}
	
	func isIncreasing(RSSI: (Int,Int,Int,Int,Int))->Bool{
		if (RSSI.0 > RSSI.1 && RSSI.1 > RSSI.2 && RSSI.2 > RSSI.3 && RSSI.3 > RSSI.4){
			return true;
		}else{
			return false;
		}
	}
	
	func isDecreasing(RSSI: (Int,Int,Int,Int,Int))->Bool{
		if (RSSI.0 < RSSI.1 && RSSI.1 < RSSI.2 && RSSI.2 < RSSI.3 && RSSI.3 < RSSI.4){
			return true;
		}else{
			return false;
		}
	}
	
	func doesNeedReset()->Int?{
		for i in 0..<needReset.count{
			if needReset[i] == 1 {
				return i
			}
		}
		return nil
	}
	
	func updateState(bData: [(Int, Int)])->Locations?{
		updateRSSI(bData)
		var foundNeighbor = false
		for i in 0..<totalBeacons {
			if(beaconState[i]==BeaconState.NEIGHBOR){
				foundNeighbor=true
				break
			}
		}
		
		for i in 0..<totalBeacons {
			switch(beaconState[i]){
			case .NOT_FOUND:
				if(beaconRSSI[i].0 != RSSI_Min){
					beaconState[i] = .FOUND
				}
				break;
			case .FOUND:
				if(!foundNeighbor && isPeak(RSSI: beaconRSSI[i])){
					beaconState[i] = .JUST_LEFT
					needReset[i] = 1
				}else if(beaconRSSI[i].0 == RSSI_Min){
					beaconState[i] = .NOT_FOUND
				}else if ((i>0 && i<14 && (beaconState[i+1] == .JUST_LEFT || beaconState[i-1] == .JUST_LEFT)) || (i==0 && beaconState[i+1] == .JUST_LEFT) || (i==14 && beaconState[i-1] == .JUST_LEFT)){
					beaconState[i] = .NEIGHBOR
				}
				break;
			case .JUST_LEFT:
				if ((i>0 && i<14 && (beaconState[i+1] == .JUST_LEFT || beaconState[i-1] == .JUST_LEFT)) || (i==0 && beaconState[i+1] == .JUST_LEFT) || (i==14 && beaconState[i-1] == .JUST_LEFT))
				{
					beaconState[i] = .NEIGHBOR
				}
				needReset[i] = 0
				break;
			case .NEIGHBOR:
				if (isPeak(RSSI: beaconRSSI[i])){
					if (i==14){
						if (beaconState[i-1] == .JUST_LEFT && isDecreasing(RSSI: beaconRSSI[i-1]))
						{
							beaconState[i] = .JUST_LEFT
							needReset[i] = 1
						}
						
					}
					else if (i==0){
						if (beaconState[i+1] == .JUST_LEFT && isDecreasing(RSSI: beaconRSSI[i+1]))
						{
							beaconState[i] = .JUST_LEFT
							needReset[i] = 1
						}
					}
					else if (beaconState[i-1] == .JUST_LEFT && isDecreasing(RSSI: beaconRSSI[i-1]))
					{
						beaconState[i] = .JUST_LEFT
						needReset[i] = 1
					}
					else if (beaconState[i+1] == .JUST_LEFT && isDecreasing(RSSI: beaconRSSI[i+1]))
					{
						beaconState[i] = .JUST_LEFT
						needReset[i] = 1
					}
				}
				else if ((i>0 && i<14 && (beaconState[i+1] != .JUST_LEFT && beaconState[i-1] != .JUST_LEFT)) || (i==0 && beaconState[i+1] != .JUST_LEFT) || (i==14 && beaconState[i-1] != .JUST_LEFT)){
					beaconState[i] = .FOUND;
				}
				break;
			}
		}
		print("\(beaconRSSI)\n")
		print("\(beaconState)\n")

		return Locations.getLocation(id: doesNeedReset())
	}
	
	
	
}
