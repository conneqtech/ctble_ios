//
//  DeviceDetailViewController.swift
//  ctble_Example
//
//  Created by Gert-Jan Vercauteren on 11/01/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import ctble

class DeviceDetailViewController: UITableViewController {
    
    let bikeInformationSubtitles = [
        "Bike type",
        "Serial number bike",
        "Serial number battery",
        "Bike software version",
        "Controller software version",
        "Display software version",
        "Bike design capacity",
        "Wheel diameter",
        "IMEI"
    ]
    
    var device: CK300Device!
    
    override func viewDidLoad() {
        if let connectedDevice = CTBleManager.shared.connectedDevice {
            super.viewDidLoad()
            title = connectedDevice.peripheral.name!
        }
    }
}

//MARK: - UITableViewDataSource
extension DeviceDetailViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return bikeInformationSubtitles.count
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Location"
        case 1:
            return "Static information"
        default:
            return "TBI"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCell(withIdentifier: "staticInformationCell", for: indexPath)
        
        if indexPath.section == 0 {
            cell = self.tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
            cell.textLabel?.text = "Show location"
        }
        
        if indexPath.section == 1 {
            cell.textLabel?.text = "-"
            cell.detailTextLabel?.text = bikeInformationSubtitles[indexPath.row].uppercased()
        }
        return cell
    }
    
}

//MARK: - UITableViewDelegate
extension DeviceDetailViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "deviceMapViewController")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

