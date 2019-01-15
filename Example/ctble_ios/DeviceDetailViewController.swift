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

struct TableSection {
    var title: String
    var items: [String]
    var cellIdentifier: String
    var lastUpdated: Date?
}

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
    
    var sections: [TableSection] = []
    
    var device: CK300Device!
    var bikeInformation: CTBikeInformation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sections = [
            TableSection(title: "🚴‍♀️ Bike information - 1051", items: bikeInformationSubtitles, cellIdentifier: "subtitleCell", lastUpdated: nil),
            TableSection(title: "🗺 Location - 1052", items: ["Show location"], cellIdentifier: "titleCell", lastUpdated: nil),
            TableSection(title: "📱 as a display", items: ["Show display"], cellIdentifier: "titleCell", lastUpdated: nil),
        ]
        
        guard let connectedDevice = CTBleManager.shared.connectedDevice else {
            title = "Test dummy"
            return
        }
        
        title = connectedDevice.peripheral.name!
        connectedDevice.getBikeInformation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CTVariableInformationService.shared.delegate = self
    }
}

//MARK: - UITableViewDataSource
extension DeviceDetailViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionData = sections[indexPath.section]
        
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: sectionData.cellIdentifier, for: indexPath)
        
        if sectionData.cellIdentifier == "titleCell" {
            cell.textLabel?.text = sectionData.items[indexPath.row]
        } else {
            cell.detailTextLabel?.text = sectionData.items[indexPath.row]
        }
        
        if indexPath.section == 0 {
            if let info = bikeInformation {
                var textToShow = "-"
                switch indexPath.row {
                case 0:
                    textToShow = info.bikeStatus == 1 ? "ON" : "OFF"
                case 1:
                    textToShow = "\(Double(info.speed) / 10) km/h"
                case 2:
                    textToShow = "\(info.range) km"
                case 3:
                    textToShow = "\(Double(info.odometer) / 1000) km"
                case 4:
                    textToShow = "\(info.bikeBatterySOC) mAh/mWh"
                case 5:
                    textToShow = "\(info.bikeBatterySOCPercentage)%"
                case 6:
                    textToShow = "\(info.supportMode)"
                case 7:
                    textToShow = info.lightStatus == 1 ? "ON" : "OFF"
                default:
                    break
                }
                
                cell.textLabel?.text = textToShow
            } else {
                cell.textLabel?.text = "-"
            }
        }

        return cell
    }
}

//MARK: - UITableViewDelegate
extension DeviceDetailViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var viewToUse = ""
        
        if indexPath.section == 2 {
            viewToUse = "phoneAsDisplay"
        }
        
        if indexPath.section == 1 {
            viewToUse = "deviceMapViewController"
        }
        
        if viewToUse != "" {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewToUse)
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
