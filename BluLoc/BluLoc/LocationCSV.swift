//
//  LocationCSV.swift
//  BluLoc
//
//  Created by Zack Rhodes on 12/7/16.
//  Copyright © 2016 zhrhode2. All rights reserved.
//

import Foundation


struct LocationCSV {
	
	var data: String!
	let columns: Int = 4
	var startDate: Date! = Date()
	
	init(){
		data = String()
	}
	
	/* Must append exactly one row of items or will fail and return false */
	mutating func appendRow(items: [String])->Bool{
		for x in 0..<columns {
			if(x == columns - 1){
				data.append(items[x] + "\n")
			}else{
				data.append(items[x] + ",")
			}
		}
		return true
	}
	
	mutating func exportData(){
		print(createFilename())
		let filename = getDocumentsDirectory().appendingPathComponent(createFilename())
		do{
			print(data)
			try data.write(toFile: filename, atomically: true, encoding: String.Encoding.utf8)
			print("written")
		} catch {
			print("failed to write:")
			print(error)
		}
		
	}
	
	func getDocumentsDirectory() -> NSString {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		let documentsDirectory = paths[0]
		return documentsDirectory as NSString
	}
	
	mutating func createFilename()->String{
		return startDate.formatDateForCSV() + "Location.csv"
	}
	
	
}
