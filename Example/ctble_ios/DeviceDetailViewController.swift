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
import RxSwift

struct TableSection {
    var identifier: String
    var title: String
    var items: [String]
    var cellIdentifier: String
    var lastUpdated: Date?
}

class DeviceDetailViewController: UITableViewController {
    
    
    let staticInformationSubtitles = [
        "Bike type",
        "Serial number bike",
        "Serial number battery",
        "Bike software version",
        "Controller software version",
        "Display software version",
        "Bike design capacity",
        "Wheel diameter",
        "BLE Version",
        "AIR Version"
    ]
    
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
        "Backup battery voltage",
        "Backup battery percentage",
        "Bike actual current"
    ]
    
    let motorInformationSubtitles = [
        "Actual torque",
        "Bike wheel speed",
        "Motor power",
        "Motor error",
        "Pedal cadence",
        "Pedal power",
        "Received signal strength"
    ]
    
    
    
    var sections: [TableSection] = []
    var reloadTimer: Timer!
    
    var device: CK300Device!
    var bikeInformation: CKBikeInformationData?
    var batteryInformation: CKBatteryInformationData?
    var motorInformation: CKMotorInformationData?
    var staticInfomation: CKStaticInformationData?
    
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sections = [
            TableSection(identifier: "static_info", title: "⚡️ Static information - 1020", items: staticInformationSubtitles, cellIdentifier: "subtitleCell", lastUpdated: nil),
            TableSection(identifier: "bike_info", title: "🚴‍♀️ Bike information - 1051", items: bikeInformationSubtitles, cellIdentifier: "subtitleCell", lastUpdated: nil),
            TableSection(identifier: "location", title: "🗺 Location - 1052", items: ["Show location"], cellIdentifier: "titleCell", lastUpdated: nil),
            TableSection(identifier: "battery_info", title: "🔋 Battery information - 1053", items: batteryInformationSubtitles, cellIdentifier: "subtitleCell", lastUpdated: nil),
            TableSection(identifier: "motor_info", title: "ℹ️ Motor information - 1054", items: motorInformationSubtitles, cellIdentifier: "subtitleCell", lastUpdated: nil),
            TableSection(identifier: "phone_as_display", title: "⚙️ Utilities", items: ["Logging"], cellIdentifier: "titleCell", lastUpdated: nil),
        ]
        
        guard let connectedDevice = CTBleManager.shared.connectedDevice else {
            title = "Test dummy"
            return
        }
    
        title = connectedDevice.peripheral.name!
        connectedDevice.getBikeInformation()
        connectedDevice.getStaticInformation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToBikeInformation()
        subscribeToBatteryInformation()
        subscribeToMotorInformation()
        subscribeToStaticInformation()
        reloadTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(reloadTableView), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        reloadTimer.invalidate()
        super.viewWillDisappear(animated)
    }
    
    @objc func reloadTableView() {
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
            let appVersionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
            let buildNumber: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String

            return "V\(appVersionString) build: \(buildNumber)"
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
        
        if sectionData.identifier == "static_info" {
            if let info = staticInfomation {
                sections[indexPath.section].lastUpdated = Date()
                
                var textToShow = "-"
                switch indexPath.row {
                case 0:
                    textToShow = info.bikeType
                case 1:
                    textToShow = info.bikeSerialNumber
                case 2:
                    textToShow = info.batterySerialNumber
                case 3:
                    textToShow = info.bikeSoftwareVersion
                case 4:
                    textToShow = info.controllerSoftwareVersion
                case 5:
                    textToShow = info.displaySoftwareVersion
                case 6:
                    textToShow = "\(info.bikeDesignCapacity)mAh/mWh"
                case 7:
                    textToShow = "\(info.wheelDiameter)mm"
                case 8:
                    textToShow = info.bleVersion
                case 9:
                    textToShow = info.airVersion
                default:
                    break
                }
                
                if textToShow == "" {
                    textToShow = "NOT SET"
                }
                
                cell.textLabel?.text = textToShow
            } else {
                cell.textLabel?.text = "-"
            }
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
                case 8:
                    textToShow = "\(info.backupBatteryPercentage)%"
                case 9:
                    textToShow = "\(info.bikeBatteryActualCurrent)mA"
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
            switch indexPath.row {
            case 0:
                viewToUse = "logViewController"
            case 1:
                viewToUse = "phoneAsDisplay"
            default:
                viewToUse = "phoneAsDisplay"
            }
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

extension DeviceDetailViewController {
    
    func subscribeToBikeInformation() {
        CTVariableInformationService.shared.bikeInformationSubject.subscribe(onNext: { bikeInformation in
            self.bikeInformation = bikeInformation
        }).disposed(by: disposeBag)
    }
    
    func subscribeToBatteryInformation() {
        CTVariableInformationService.shared.batteryInformationSubject.subscribe(onNext: { batteryInformation in
           self.batteryInformation = batteryInformation
        }).disposed(by: disposeBag)
    }

    func subscribeToMotorInformation() {
        CTVariableInformationService.shared.motorInformationSubject.subscribe(onNext: { motorInformation in
            self.motorInformation = motorInformation
        }).disposed(by: disposeBag)
    }
    
    func subscribeToStaticInformation() {
        CTStaticInformationService.shared.staticInformationSubject.subscribe(onNext: { staticInformation in
            self.staticInfomation = staticInformation
        }).disposed(by: disposeBag)
    }
}
