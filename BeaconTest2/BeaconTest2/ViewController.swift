//
//  ViewController.swift
//  BeaconTest2
//
//  Created by Pujan Dave on 11/12/16.
//  Copyright © 2016 Pujan Dave. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView?
    var beacons: [CLBeacon] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    }

extension ViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView,
                           numberOfRowsInSection section: Int) -> Int {
        if(beacons.count > 0) {
            return beacons.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell? =
            tableView.dequeueReusableCell(withIdentifier: "MyIdentifier")
        
        if(cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle,
                                   reuseIdentifier: "MyIdentifier")
            cell!.selectionStyle = UITableViewCellSelectionStyle.none
        }
        
        let beacon:CLBeacon = beacons[indexPath.row]
        var proximityLabel:String! = ""
        
        switch beacon.proximity {
        case CLProximity.far:
            proximityLabel = "Far"
        case CLProximity.near:
            proximityLabel = "Near"
        case CLProximity.immediate:
            proximityLabel = "Immediate"
        case CLProximity.unknown:
            proximityLabel = "Unknown"
        }
        
        cell!.textLabel?.text = proximityLabel
        
        let detailLabel:String = "Major: \(beacon.major.intValue), " +
            "Minor: \(beacon.minor.intValue), " +
            "RSSI: \(beacon.rssi as Int), " +
        "UUID: \(beacon.proximityUUID.uuidString)"
        cell!.detailTextLabel?.text = detailLabel
        
        return cell!
    }
    

}

