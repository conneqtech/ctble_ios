//
//  CKStaticInformationService.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 14/01/2019.
//

import Foundation
import CoreBluetooth

public struct CKStaticInformationService: CTBleServiceProtocol {
    public let UUID: CBUUID = CBUUID(string: "003065A4-1020-11E8-A8D5-435154454348")
    public let name: String = "static_information"
    public let type: CTBleServiceType = .unauthenticated

    public var characteristics: [CTBleCharacteristic] = [
//        CTBleCharacteristic(name: "bike_type",
//                            UUID: CBUUID(string: "003065A4-1021-11E8-A8D5-435154454348"),
//                            type: .ascii),
//
//        CTBleCharacteristic(name: "serial_number_bike",
//                            UUID: CBUUID(string: "003065A4-1022-11E8-A8D5-435154454348"),
//                            type: .ascii),
//
//        CTBleCharacteristic(name: "serial_number_battery",
//                            UUID: CBUUID(string: "003065A4-1023-11E8-A8D5-435154454348"),
//                            type: .ascii),
//
//        CTBleCharacteristic(name: "bike_software_version",
//                            UUID: CBUUID(string: "003065A4-1024-11E8-A8D5-435154454348"),
//                            type: .ascii),
//
//        CTBleCharacteristic(name: "controller_software_version",
//                            UUID: CBUUID(string: "003065A4-1025-11E8-A8D5-435154454348"),
//                            type: .ascii),
//
//        CTBleCharacteristic(name: "display_software_version",
//                            UUID: CBUUID(string: "003065A4-1026-11E8-A8D5-435154454348"),
//                            type: .ascii),
//
//        CTBleCharacteristic(name: "bike_design_capacity",
//                            UUID: CBUUID(string: "003065A4-1027-11E8-A8D5-435154454348"),
//                            type: .ascii),
//
//        CTBleCharacteristic(name: "wheel_diameter",
//                            UUID: CBUUID(string: "003065A4-1028-11E8-A8D5-435154454348"),
//                            type: .ascii),
//
//        CTBleCharacteristic(name: "ble_version",
//                            UUID: CBUUID(string: "003065A4-1029-11E8-A8D5-435154454348"),
//                            type: .ascii),
//        CTBleCharacteristic(name: "air_version",
//                            UUID: CBUUID(string: "003065A4-1030-11E8-A8D5-435154454348"),
//                            type: .ascii)
    ]
    
    public func setup(withDevice device: CK300Device) {
        // Setup here
        print("🐛 Setting up staticInformation")
        let service = device.peripheral.services?.filter { service in
            service.uuid == self.UUID
        }
        
        if let service = service, service.count > 0 {
            service[0].characteristics?.forEach { characteristic in
                handleEvent(peripheral: device.peripheral, characteristic: characteristic, type: .discover)
            }
        }
    }

    public func handleEvent(peripheral: CBPeripheral, characteristic: CBCharacteristic, type: CTBleEventType) {
//        let localFilteredCharacteristic = self.characteristics.filter { element in
//            element.UUID == characteristic.uuid
//        }
//        
//        if localFilteredCharacteristic.count == 0 {
//            return
//        }
//        var localCharacteristic = localFilteredCharacteristic[0]
//
////        localCharacteristic.characteristic = characteristic
////        characteristics.updateValue(localCharacteristic, forKey: characteristic.uuid.uuidString)
//
//        switch type {
//        case .discover:
//            peripheral.setNotifyValue(true, for: characteristic)
//        case .notification:
//             peripheral.readValue(for: characteristic)
//        case .update:
//            if let data = characteristic.value {
//                if let rawString = String(data: data, encoding: .ascii) {
//                    if let cString = rawString.cString(using: .utf8) {
//                        let actualString = String(cString: cString)
//    
//                        switch characteristic.uuid.uuidString {
//                        case "003065A4-1021-11E8-A8D5-435154454348":
//                            CTStaticInformationService.shared.data.bikeType = actualString
//                        case "003065A4-1022-11E8-A8D5-435154454348":
//                            CTStaticInformationService.shared.data.bikeSerialNumber = actualString
//                        case "003065A4-1023-11E8-A8D5-435154454348":
//                            CTStaticInformationService.shared.data.batterySerialNumber = actualString
//                        case "003065A4-1024-11E8-A8D5-435154454348":
//                            CTStaticInformationService.shared.data.bikeSoftwareVersion = actualString
//                        case "003065A4-1025-11E8-A8D5-435154454348":
//                            CTStaticInformationService.shared.data.controllerSoftwareVersion = actualString
//                        case "003065A4-1026-11E8-A8D5-435154454348":
//                            CTStaticInformationService.shared.data.displaySoftwareVersion = actualString
//                        case "003065A4-1027-11E8-A8D5-435154454348":
//                            CTStaticInformationService.shared.data.bikeDesignCapacity = Int(data[0])
//                        case "003065A4-1028-11E8-A8D5-435154454348":
//                            let wheelDiameter = data.withUnsafeBytes {
//                                (pointer: UnsafePointer<UInt16>) -> UInt16 in
//                                return pointer.pointee
//                            }
//                            
//                            CTStaticInformationService.shared.data.wheelDiameter = Int(wheelDiameter)
//                        case "003065A4-1029-11E8-A8D5-435154454348":
//                            CTStaticInformationService.shared.data.bleVersion = actualString
//                        case "003065A4-1030-11E8-A8D5-435154454348":
//                            CTStaticInformationService.shared.data.airVersion = actualString
//                        default:
//                            break
//                        }
//                        
//                        CTStaticInformationService.shared.updateStaticInformation()
//                    }
//                }
//            }
//        default:
//            break
//        }
    }
}
