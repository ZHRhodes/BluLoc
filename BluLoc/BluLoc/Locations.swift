//
//  Locations.swift
//  BluLoc
//
//  Created by Zack Rhodes on 12/4/16.
//  Copyright © 2016 zhrhode2. All rights reserved.
//

import Foundation

struct Location {
	var immPt: (x: Int, y: Int)
	var nearPt: (x: Int, y: Int)
	var major: Int!
	var minor: Int!
	var id: Int!
	var radius: (R_im: Int, R_near: Int, R_far: Int)!
	
	init(imm: (x: Int, y: Int), near: (x: Int, y: Int), major: Int, minor: Int, id: Int, radius: (Int,Int,Int)){
		immPt = imm
		nearPt = near
		self.major = major
		self.minor = minor
		self.id = id
		self.radius = radius
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
			return Location(imm: (460, 2230), near: (500, 2260), major: 65122, minor: 59387, id: 0, radius: (25, 175, 400))//(460,2230) //14
		case .room_2013:
			return Location(imm: (1360, 2230), near: (1360, 2230), major: 13226, minor: 33616, id: 1, radius: (25, 175, 400))//(1360,2230) //15 //58327 //id changed to 12
		case .room_2008:
			return Location(imm: (1875, 2015), near: (1830, 2015), major: 18162, minor: 49481, id: 2, radius: (25, 270, 460))//(1875,2015) //16
		case .room_1000Window:
			return Location(imm: (1695, 1520), near: (1800, 1520), major: 58099, minor: 58863, id: 3, radius: (25, 217, 400))//(1695,1520) //17
		case .room_atriumStairs:
			return Location(imm: (1780, 990), near: (1770, 990), major: 46250, minor: 64969, id: 4, radius: (25, 220, 400))//(1860,1040) //18
		case .room_2036:
			return Location(imm: (1460, 530), near: (1460, 560), major: 44016, minor: 51524, id: 5, radius: (25, 175, 400))//(1460,530) //19 //44016
		case .room_2076:
			return Location(imm: (1950, 610), near: (1950, 590), major: 11111, minor: 31219, id: 6, radius: (25, 175, 400))//(1950,610) //20
		case .room_stair2:
			return Location(imm: (2460, 530), near: (2430, 550), major: 12879, minor: 63061, id:7, radius: (25, 175, 400))//(2460,530) //21
		case .room_openLab:
			return Location(imm: (965, 610), near: (965, 610), major: 55473, minor: 36184, id: 8, radius: (25, 175, 400))//(965,610) //22
		case .room_stair3:
			return Location(imm: (510, 535), near: (535, 560), major: 31421, minor: 19040, id:9, radius: (25, 175, 400))//(510,535) //13 //now 11
			
		}
	}
	
	static func getId(major: Int)->Int?{
		switch(major){
		case 65122:
			return 0
		case 13226: //58327
			return 1
		case 18162:
			return 2
		case 58099:
			return 3
		case 46250:
			return 4
		case 44016: //44016
			return 5
		case 11111:
			return 6
		case 12879:
			return 7
		case 55473:
			return 8
		case 31421:
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
				return .room_2013
			case 2:
				return .room_2008
			case 3:
				return .room_1000Window
			case 4:
				return .room_atriumStairs
			case 5:
				return .room_2036
			case 6:
				return .room_2076
			case 7:
				return .room_stair2
			case 8:
				return .room_openLab
			case 9:
				return .room_stair3
			default:
				return nil
			}
		}
		return nil
	}

}
