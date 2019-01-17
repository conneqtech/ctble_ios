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
    var identifier: String
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
    
    let batteryInformationSubtitles = [
        "FCC mAh/mWh",
        "FCC percentage",
        "Charging cycles",
        "Pack voltage",
        "Temperature",
        "Errors",
        "State",
        "Backup battery voltage"
    ]
    
    let motorInformationSubtitles = [
        "Actual torque",
        "Bike wheel speed",
        "Motor power",
        "Motor erorrs",
        "Pedal cadence",
        "Pedal power",
        "Received signal strength"
    ]
    
    
    
    var sections: [TableSection] = []
    var reloadTimer: Timer!
    
    var device: CK300Device!
    var bikeInformation: CTBikeInformation?
    var batteryInformation: CTBatteryInformation?
    var motorInformation: CTMotorInformation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sections = [
            TableSection(identifier: "bike_info", title: "🚴‍♀️ Bike information - 1051", items: bikeInformationSubtitles, cellIdentifier: "subtitleCell", lastUpdated: nil),
            TableSection(identifier: "location", title: "🗺 Location - 1052", items: ["Show location"], cellIdentifier: "titleCell", lastUpdated: nil),
            TableSection(identifier: "battery_info", title: "🔋 Battery information - 1053", items: batteryInformationSubtitles, cellIdentifier: "subtitleCell", lastUpdated: nil),
            TableSection(identifier: "motor_info", title: "ℹ️ Motor information - 1054", items: motorInformationSubtitles, cellIdentifier: "subtitleCell", lastUpdated: nil),
            TableSection(identifier: "phone_as_display", title: "📱 as a display", items: ["Show display"], cellIdentifier: "titleCell", lastUpdated: nil),
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
        reloadTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(reloadTableView), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        reloadTimer.invalidate()
        super.viewWillDisappear(animated)
    }
    
    @objc func reloadTableView() {
        print("Reload")
        self.tableView.reloadData()
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
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let lastUpdated = sections[section].lastUpdated {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            return "Last updated: \(dateFormatter.string(from: lastUpdated))"
        }
        
        if sections[section].cellIdentifier == "titleCell" {
            return ""
        }
        
        return "Never updated"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionData = sections[indexPath.section]
        
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: sectionData.cellIdentifier, for: indexPath)
        
        if sectionData.cellIdentifier == "titleCell" {
            cell.textLabel?.text = sectionData.items[indexPath.row]
        } else {
            cell.detailTextLabel?.text = sectionData.items[indexPath.row]
        }
        
        if sectionData.identifier == "bike_info" {
            if let info = bikeInformation {
                sections[indexPath.section].lastUpdated = Date()
        
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
        
        if sectionData.identifier == "battery_info" {
            if let info = batteryInformation {
                sections[indexPath.section].lastUpdated = Date()
                
                var textToShow = "-"
                switch indexPath.row {
                case 0:
                    textToShow = "\(info.fccMah) mAh/mWh"
                case 1:
                    textToShow = "\(info.fccPercentage)%"
                case 2:
                    textToShow = "\(info.chargingCycles)"
                case 3:
                    textToShow = "\(Double(info.packVoltage) / 100)V"
                case 4:
                    textToShow = "\(info.temperature)C/K"
                case 5:
                    
                    textToShow = info.errors.replacingOccurrences(of: " ", with: "") != "" ? "\(info.errors)" : "-"
                case 6:
                    switch info.state {
                    case 0:
                        textToShow = "rest"
                    case 1:
                        textToShow = "charge"
                    case 2:
                        textToShow = "discharge"
                    case 3:
                        textToShow = "disconnected"
                    default:
                        textToShow = "UNKNOWN"
                    }
                case 7:
                    textToShow = "\(info.backupBatteryVoltage)mV"
                default:
                    break
                }
        
                cell.textLabel?.text = textToShow
            } else {
                cell.textLabel?.text = "-"
            }
        }
        
        if sectionData.identifier == "motor_info" {
            if let info = motorInformation {
                sections[indexPath.section].lastUpdated = Date()
                
                var textToShow = "-"
                switch indexPath.row {
                case 0:
                    textToShow = "\(Double(info.actualTorque) / 100) Nm"
                case 1:
                    textToShow = "\(info.wheelSpeed) RPM"
                case 2:
                    textToShow = "\(info.motorPower) W"
                case 3:
                    textToShow = info.motorError.replacingOccurrences(of: " ", with: "") != "" ? "\(info.motorError)" : "-"
                case 4:
                    textToShow = "\(info.pedalCadence) RPM"
                case 5:
                    textToShow = "\(info.pedalPower) W"
                case 6:
                    textToShow = "\(info.receivedSignalStrength) dbm"
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
        let sectionData = sections[indexPath.section]
        
        var viewToUse = ""
        
        if sectionData.identifier == "phone_as_display" {
            viewToUse = "phoneAsDisplay"
        }
        
        if sectionData.identifier == "location" {
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
        // Bad code for bad tracker :(
        if self.bikeInformation == nil {
            self.bikeInformation = bikeInformation
        } else {
            self.bikeInformation?.bikeStatus = bikeInformation.bikeStatus
            
            if bikeInformation.speed != 0 {
                self.bikeInformation?.speed = bikeInformation.speed
            }
            
            if bikeInformation.range != 0 {
                self.bikeInformation?.range = bikeInformation.range
            }
            
            if bikeInformation.odometer != 0 {
                self.bikeInformation?.odometer = bikeInformation.odometer
            }
            
            if bikeInformation.bikeBatterySOC != 0 {
                self.bikeInformation?.bikeBatterySOC = bikeInformation.bikeBatterySOC
            }
            
            if bikeInformation.bikeBatterySOCPercentage != 0 {
                self.bikeInformation?.bikeBatterySOCPercentage = bikeInformation.bikeBatterySOCPercentage
            }
            
            if bikeInformation.supportMode != 0 {
                self.bikeInformation?.supportMode = bikeInformation.supportMode
            }
        
            self.bikeInformation?.lightStatus = bikeInformation.lightStatus
        }
    }
    
    func didUpdateBatteryInformation(_ batteryInformation: CTBatteryInformation) {
        
        if self.batteryInformation == nil {
            self.batteryInformation = batteryInformation
        } else {
            if batteryInformation.fccMah != 0 {
                self.batteryInformation?.fccMah = batteryInformation.fccMah
            }
            
            if batteryInformation.fccPercentage != 0 {
                self.batteryInformation?.fccPercentage = batteryInformation.fccPercentage
            }
            
            if batteryInformation.chargingCycles != 0 {
                self.batteryInformation?.chargingCycles = batteryInformation.chargingCycles
            }
            
            if batteryInformation.packVoltage != 0 {
                self.batteryInformation?.packVoltage = batteryInformation.packVoltage
            }
            
            if batteryInformation.temperature != 0 {
                self.batteryInformation?.temperature = batteryInformation.temperature
            }
            
            if batteryInformation.errors != "" {
                self.batteryInformation?.errors = batteryInformation.errors
            }
            
            if batteryInformation.state != 0 {
                self.batteryInformation?.state = batteryInformation.state
            }
            
            if batteryInformation.backupBatteryVoltage != 0 {
                self.batteryInformation?.backupBatteryVoltage = batteryInformation.backupBatteryVoltage
            }
        }
    }
    
    func didUpdateMotorInformation(_ motorInformation: CTMotorInformation) {
        self.motorInformation = motorInformation
    }
}
