//
//  Locations.swift
//  BluLoc
//
//  Created by Zack Rhodes on 12/4/16.
//  Copyright © 2016 zhrhode2. All rights reserved.
//

import Foundation

struct Location {
	var x: Int!
	var y: Int!
	var major: Int!
	var minor: Int!
	var id: Int!
	
	init(x: Int, y: Int, major: Int, minor: Int, id: Int){
		self.x = x
		self.y = y
		self.major = major
		self.minor = minor
		self.id = id
	}
}

enum Locations: String {
	case room_2017 = "Room 2017"
	case room_2013 = "Room 2013"
	case room_2008 = "Room 2008"
	case room_1000Window = "Room 1000 Window"
	case room_atriumStairs = "Atrium Stairs"
	case room_2036 = "Room 2036"
	case room_2076 = "Room 2076"
	case room_stair2 = "Northeast Stairwell"
	case room_openLab = "Open Lab"
	case room_stair3 = "Northwest Stairwell"
	
	static let locationSet1 = [room_2017, room_2008, room_atriumStairs, room_2076, room_openLab]
	static let locationSet2 = [room_2013, room_1000Window, room_2036, room_stair2, room_stair3]
	static let allLocations = locationSet1 + locationSet2
}

extension Locations {
	func location()->Location{
		switch self{
		case .room_2017:
			return Location(x: 460, y: 2230, major: 65122, minor: 59387, id: 0)//(460,2230) //14
		case .room_2013:
			return Location(x: 1360, y: 2230, major: 58327, minor: 23618, id: 1)//(1360,2230) //15
		case .room_2008:
			return Location(x: 1875, y: 2015, major: 48125, minor: 15238, id: 2)//(1875,2015) //16
		case .room_1000Window:
			return Location(x: 1695, y: 1520, major: 58099, minor: 58863, id: 3)//(1695,1520) //17
		case .room_atriumStairs:
			return Location(x: 1860, y: 1040, major: 46250, minor: 64969, id: 4)//(1860,1040) //18
		case .room_2036:
			return Location(x: 1460, y: 530, major: 44016, minor: 51524, id: 5)//(1460,530) //19
		case .room_2076:
			return Location(x: 1950, y: 610, major: 11111, minor: 31219, id: 6)//(1950,610) //20
		case .room_stair2:
			return Location(x: 2460, y: 530, major: 12879, minor: 63061, id:7)//(2460,530) //21
		case .room_openLab:
			return Location(x: 965, y: 610, major: 55473, minor: 36184, id: 8)//(965,610) //22
		case .room_stair3:
			return Location(x: 510, y: 535, major: 61824, minor: 4248, id:9)//(510,535) //13
			
		}
	}
	
	static func getId(major: Int)->Int?{
		switch(major){
		case 65122:
			return 0
		case 58327:
			return 1
		case 48125:
			return 2
		case 58099:
			return 3
		case 46250:
			return 4
		case 44016:
			return 5
		case 11111:
			return 6
		case 12879:
			return 7
		case 55473:
			return 8
		case 61824:
			return 9
		default:
			return nil
		}
	}
	
	static func getLocation(id: Int?)->Locations?{
		if let mId = id {
			switch(mId){
			case 0:
				return .room_2017
			case 1:
				return .room_2017
			case 2:
				return .room_2017
			case 3:
				return .room_2017
			case 4:
				return .room_2017
			case 5:
				return .room_2017
			case 6:
				return .room_2017
			case 7:
				return .room_2017
			case 8:
				return .room_2017
			case 9:
				return .room_2017
			default:
				return nil
			}
		}
		return nil
	}

}
