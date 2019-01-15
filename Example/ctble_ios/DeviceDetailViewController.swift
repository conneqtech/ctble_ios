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
    
    let bikeStaticInformationSubtitles = [
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
    
    let bikeInformationSubtitles = [
        "Bike status",
        "Speed",
        "Range",
        "Odometer",
        "Bike battery SOC mAh/mWh",
        "Bike battery SOC percentage",
        "Support mode",
        "Light status"
    ]
    
    var device: CK300Device!
    var bikeInformation: CTBikeInformation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let connectedDevice = CTBleManager.shared.connectedDevice {
            title = connectedDevice.peripheral.name!
            connectedDevice.getBikeInformation()
            
            CTVariableInformationService.shared.delegate = self
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
        case 2:
            return bikeStaticInformationSubtitles.count
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Location - 1052"
        case 1:
            return "Bike information - 1051"
        case 2:
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
            if let info = bikeInformation {
                var textToShow = "-"
                switch indexPath.row {
                case 0:
                    textToShow = info.bikeStatus == 1 ? "ON" : "OFF"
                case 1:
                    textToShow = "\(info.speed) km/h"
                case 2:
                    textToShow = "\(info.range) km"
                case 3:
                    textToShow = "\(info.odometer) km"
                case 4:
                    textToShow = "\(info.bikeBatterySOC) mAh/mWh"
                case 5:
                    textToShow = "\(info.bikeBatterySOCPercentage)%"
                case 6:
                    textToShow = "\(info.supportMode)"
                case 7:
                    textToShow = "\(info.lightStatus)"
                default:
                    break
                }
                
                cell.textLabel?.text = textToShow
            } else {
                cell.textLabel?.text = "-"
            }
            
            cell.detailTextLabel?.text = bikeInformationSubtitles[indexPath.row].uppercased()
        }
        
        if indexPath.section == 2 {
            cell.textLabel?.text = "-"
            cell.detailTextLabel?.text = bikeStaticInformationSubtitles[indexPath.row].uppercased()
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

extension DeviceDetailViewController: CTVariableInformationServiceDelegate {
    func didUpdateBikeInformation(_ bikeInformation: CTBikeInformation) {
        self.bikeInformation = bikeInformation
        self.tableView.reloadData()
    }
}
