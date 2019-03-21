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
    var items: [TableRow]
    var cellIdentifier: String
    var lastUpdated: Date?
}

struct TableRow {
    let title: String
    let key: CK300Field
    let prefix: String
    let suffix: String
    
    init (title: String, key: CK300Field, prefix: String = "", suffix: String = "") {
        self.title = title
        self.key = key
        self.prefix = prefix
        self.suffix = suffix
    }
}

class DeviceDetailViewController: UITableViewController {
    
    
    let staticInformationSubtitles = [
        TableRow(title: "Bike type", key: .bikeType),
        TableRow(title: "Bike serial number", key: .bikeSerialNumber),
        TableRow(title: "Battery serial number", key: .batterySerialNumber),
        TableRow(title: "Bike software version", key: .bikeSoftwareVersion),
        TableRow(title: "Controller software version", key: .controllerSoftwareVersion),
        TableRow(title: "Display software version", key: .displaySoftwareVersion),
        TableRow(title: "Bike design capacity", key: .bikeDesignCapacity),
        TableRow(title: "Bike wheel diameter", key: .wheelDiameter),
        TableRow(title: "BLE version", key: .bleVersion),
        TableRow(title: "AIR version", key: .airVersion),
    ]
    
    let bikeInformationSubtitles: [TableRow] = [
        TableRow(title: "Bike status", key: .bikeStatus),
        TableRow(title: "Bike speed", key: .bikeSpeed, suffix: " km/h"),
        TableRow(title: "Bike range", key: .bikeRange, suffix: " km"),
        TableRow(title: "Bike odometer", key: .bikeOdometer, suffix: " m"),
        TableRow(title: "Bike battery SOC mAh/mWh", key: .bikeBatterySOC, suffix: " mAh"),
        TableRow(title: "Bike battery SOC percentage", key: .bikeBatterySOCPercentage, suffix: " %"),
        TableRow(title: "Bike support mode", key: .bikeSupportMode),
        TableRow(title: "Bike light status", key: .bikeLightStatus)
    ]
    
    let bikeBatteryInformationSubtitles: [TableRow] = [
        TableRow(title: "Bike battery FCC", key: .bikeBatteryFCC, suffix: " mAh"),
        TableRow(title: "Bike battery FCC percentage", key: .bikeBatteryFCCPercentage, suffix: " %"),
        TableRow(title: "Bike battery charging cycles", key: .bikeBatteryChargingCycles),
        TableRow(title: "Bike battery pack voltage", key: .bikeBatteryPackVoltage, suffix: " V"),
        TableRow(title: "Bike battery temperature", key: .bikeBatteryTemperature, suffix: " °C"),
        TableRow(title: "Bike battery errors", key: .bikeBatteryErrors),
        TableRow(title: "Bike battery state", key: .bikeBatteryState),
        TableRow(title: "Backup battery pack voltage", key: .backupBatteryVoltage, suffix: " mV"),
        TableRow(title: "Bike battery actual current", key: .bikeBatteryActualCurrent, suffix: " mA"),
    ]
    
    let motorInformationSubtitles: [TableRow] = [
        TableRow(title: "Actual torque", key: .bikeActualTorque, suffix: " Nm"),
        TableRow(title: "Bike wheel speed", key: .bikeWheelSpeed, suffix: " RPM"),
        TableRow(title: "Motor power", key: .motorPower, suffix: " W"),
        TableRow(title: "Motor errors", key: .motorErrors),
        TableRow(title: "Pedal cadence", key: .pedalCadence, suffix: " RPM"),
        TableRow(title: "Pedal power", key: .pedalPower, suffix: " W"),
        TableRow(title: "Received signal strength", key: .receivedSignalStrength, suffix: " dbm")
    ]
    

    var sections: [TableSection] = []
    var reloadTimer: Timer!
    
    var device: CK300Device?
    var deviceState: [CK300Field: Any] = [:]
    
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sections = [
            TableSection(identifier: "static_info",
                         title: "⚡️ Static information - 1020",
                         items: staticInformationSubtitles,
                         cellIdentifier: "subtitleCell",
                         lastUpdated: nil),
            TableSection(identifier: "bike_info",
                         title: "🚴‍♀️ Bike information - 1051",
                         items: bikeInformationSubtitles,
                         cellIdentifier: "subtitleCell",
                         lastUpdated: nil),
            
            TableSection(identifier: "location",
                         title: "🗺 Location - 1052",
                         items: [TableRow(title: "Location", key: .gpsAltitude)],
                         cellIdentifier: "titleCell",
                         lastUpdated: nil),
            TableSection(identifier: "battery_info",
                         title: "🔋 Battery information - 1053",
                         items: bikeBatteryInformationSubtitles,
                         cellIdentifier: "subtitleCell",
                         lastUpdated: nil),
            TableSection(identifier: "motor_info",
                         title: "ℹ️ Motor information - 1054",
                         items: motorInformationSubtitles,
                         cellIdentifier: "subtitleCell",
                         lastUpdated: nil),
            TableSection(identifier: "control",
                         title: "⚙️ Control",
                         items: [
                            TableRow(title: "Control", key: .bikeType),
                            TableRow(title: "Phone as a display", key: .bikeType)
                         ],
                         cellIdentifier: "titleCell",
                         lastUpdated: nil),
        ]
        
        guard let connectedDevice = CTBleManager.shared.connectedDevice else {
            title = "Test dummy"
            return
        }
        
        self.device = connectedDevice
    
        title =  self.device?.peripheral.name!
        
        self.device?.deviceStatus.subscribe(onNext: { newStatus in
            print("🐛 Device status: \(newStatus)")
            
            if newStatus == .ready {
                self.device?.getData(withServiceType: .variable)
                self.device?.getData(withServiceType: .bikeStatic)
            }
            
        }).disposed(by: disposeBag)
        self.device?.setupDevice()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let device = self.device {
            device.deviceState
                .throttle(1, scheduler: MainScheduler.instance)
                .subscribe(onNext: { newState in
                    self.deviceState = newState
                    self.tableView.reloadData()
                }).disposed(by: disposeBag)
        }
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 47.0
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if sections[section].identifier == "settings" {
            let appVersionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
            let buildNumber: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String

            return "V\(appVersionString) build: \(buildNumber)"
        }
        
        return ""
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionData = sections[indexPath.section]
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: sectionData.cellIdentifier, for: indexPath)
        
        let item = sectionData.items[indexPath.row]
        
        var textToShow = "-"
        if let info = self.deviceState[item.key] {
            textToShow = "\(item.prefix)\(info)\(item.suffix)"
        }
        
        if textToShow == "" {
            textToShow = "-"
        }
        
        cell.textLabel?.text = textToShow
        
        
        if sectionData.cellIdentifier == "titleCell" {
            cell.textLabel?.text = item.title
        } else {
            cell.detailTextLabel?.text = item.title
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension DeviceDetailViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionData = sections[indexPath.section]
        
        var viewToUse = ""
        
        if sectionData.identifier == "settings" {
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
        
        if sectionData.identifier == "control" {
            if indexPath.row == 0 {
                viewToUse = "bikeControlsTableViewController"
            }
            
            if indexPath.row == 1 {
               viewToUse = "phoneAsDisplay"
            }
        }
        
        if viewToUse != "" {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewToUse)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
