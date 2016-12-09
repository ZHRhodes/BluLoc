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
	let RSSI_Min = -1000 //what is this?
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
//		if (RSSI.0 < RSSI.1 && RSSI.1 < RSSI.2 && RSSI.2 > RSSI.3 && RSSI.3 > RSSI.4){
        if (RSSI.0 < RSSI.2 && RSSI.2 > RSSI.4 && RSSI.2 > -90){
			return true;
		}else{
			return false;
		}
	}
	
	func isIncreasing(RSSI: (Int,Int,Int,Int,Int))->Bool{
//		if (RSSI.0 > RSSI.1 && RSSI.1 > RSSI.2 && RSSI.2 > RSSI.3 && RSSI.3 > RSSI.4){
        if (RSSI.0  > RSSI.2 && RSSI.2 > RSSI.4){
			return true;
		}else{
			return false;
		}
	}
	
	func isDecreasing(RSSI: (Int,Int,Int,Int,Int))->Bool{
//		if (RSSI.0 < RSSI.1 && RSSI.1 < RSSI.2 && RSSI.2 < RSSI.3 && RSSI.3 < RSSI.4){
        if ((RSSI.0 < RSSI.2 && RSSI.2 < RSSI.4) || RSSI.2 < -90){
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
				}else if ((i>0 && i<9 && i != 7 && i != 8 && (beaconState[i+1] == .JUST_LEFT || beaconState[i-1] == .JUST_LEFT)) || (i==0 && beaconState[i+1] == .JUST_LEFT) || (i==9 && beaconState[i-1] == .JUST_LEFT) || (i==4 && beaconState[6] == .JUST_LEFT) || (i==5 && beaconState[8] == .JUST_LEFT) || (i==8 && beaconState[5] == .JUST_LEFT) || (i==6 && beaconState[4] == .JUST_LEFT) || (i==7 && beaconState[6] == .JUST_LEFT) || (i==8 && beaconState[9] == .JUST_LEFT)){
					beaconState[i] = .NEIGHBOR
				}
				break;
			case .JUST_LEFT:
				if ((i>0 && i<9 && i != 8 && i != 7 && i != 6 && i != 5 && i != 4 && (beaconState[i+1] == .JUST_LEFT || beaconState[i-1] == .JUST_LEFT)) || (i==0 && beaconState[i+1] == .JUST_LEFT) || (i==9 && beaconState[i-1] == .JUST_LEFT) || (i == 7 && beaconState[6] == .JUST_LEFT) || (i == 6 && (beaconState[5] == .JUST_LEFT || beaconState[4] == .JUST_LEFT || beaconState[7] == .JUST_LEFT)) || (i == 5 && (beaconState[4] == .JUST_LEFT || beaconState[6] == .JUST_LEFT || beaconState[8] == .JUST_LEFT)) || (i == 4 && (beaconState[3] == .JUST_LEFT || beaconState[5] == .JUST_LEFT || beaconState[6] == .JUST_LEFT)) || (i == 8 && (beaconState[5] == .JUST_LEFT || beaconState[9] == .JUST_LEFT)))
				{
					beaconState[i] = .NEIGHBOR
				}
				needReset[i] = 0
				break;
			case .NEIGHBOR:
				if (isPeak(RSSI: beaconRSSI[i])){
					if (i==9){
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
                    else if (i==7) {
                        if ((beaconState[6] == .JUST_LEFT && isDecreasing(RSSI: beaconRSSI[6])))
                        {
                            beaconState[i] = .JUST_LEFT
                            needReset[i] = 1
                        }
                    }
                    else if (i==4)
                    {
                        if ((beaconState[6] == .JUST_LEFT && isDecreasing(RSSI: beaconRSSI[6])) || (beaconState[5] == .JUST_LEFT && isDecreasing(RSSI: beaconRSSI[5])) || (beaconState[3] == .JUST_LEFT && isDecreasing(RSSI: beaconRSSI[3])))
                        {
                            beaconState[i] = .JUST_LEFT
                            needReset[i] = 1
                        }
                    }
                    else if (i==5)
                    {
                        if((beaconState[6] == .JUST_LEFT && isDecreasing(RSSI: beaconRSSI[6])) || (beaconState[8] == .JUST_LEFT && isDecreasing(RSSI: beaconRSSI[8])) || (beaconState[4] == .JUST_LEFT && isDecreasing(RSSI: beaconRSSI[4])))
                        {
                            beaconState[i] = .JUST_LEFT
                            needReset[i] = 1
                        }
                    }
                    else if(i==6)
                    {
                        if((beaconState[7] == .JUST_LEFT && isDecreasing(RSSI: beaconRSSI[7])) || (beaconState[8] == .JUST_LEFT && isDecreasing(RSSI: beaconRSSI[8])) || (beaconState[4] == .JUST_LEFT && isDecreasing(RSSI: beaconRSSI[4])))
                        {
                            beaconState[i] = .JUST_LEFT
                            needReset[i] = 1
                        }
                    }
                    else if (i==2){
                        if(beaconRSSI[i].2 > -65 && ((beaconState[i-1] == .JUST_LEFT && isDecreasing(RSSI: beaconRSSI[i-1])) || (beaconState[i+1] == .JUST_LEFT && isDecreasing(RSSI: beaconRSSI[i+1]))))
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
				else if ((i>0 && i<9 && i != 7 && i != 8 && i != 4 && i != 5 && i != 6 && beaconState[i+1] != .JUST_LEFT && beaconState[i-1] != .JUST_LEFT) || (i==0 && beaconState[i+1] != .JUST_LEFT) || (i==9 && beaconState[i-1] != .JUST_LEFT) || (i==4 && beaconState[6] != .JUST_LEFT && beaconState[5] != .JUST_LEFT && beaconState[3] != .JUST_LEFT) || (i==7 && beaconState[6] != .JUST_LEFT) || (i==6 && beaconState[4] != .JUST_LEFT && beaconState[5] != .JUST_LEFT && beaconState[7] != .JUST_LEFT) || (i==5 && beaconState[8] != .JUST_LEFT && beaconState[6] != .JUST_LEFT && beaconState[4] != .JUST_LEFT) || (i==8 && beaconState[5] != .JUST_LEFT && beaconState[9] != .JUST_LEFT)){
					beaconState[i] = .FOUND;
				}
				break;
			}
		}
//		print("\(beaconRSSI)\n")
//		print("\(beaconState)\n")
//        print("\(needReset)\n")
//        print(Locations.getLocation(id: doesNeedReset()))

		return Locations.getLocation(id: doesNeedReset())
	}
	
	
	
}
