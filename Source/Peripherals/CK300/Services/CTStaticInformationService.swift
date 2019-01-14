//
//  CTStaticInformationService.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 14/01/2019.
//

import Foundation
import CoreBluetooth

public struct CTStaticInformationService: CTBleServiceProtocol {
    public let UUID: CBUUID = CBUUID(string: "003065A4-1020-11E8-A8D5-435154454348")
    public let name: String = "static_information"
    public let type: CTBleServiceType = .unauthenticated

    public var characteristics: [String: CTBleCharacteristic] = [
        "003065A4-1021-11E8-A8D5-435154454348": CTBleCharacteristic(name: "bike_type",
                            UUID: CBUUID(string: "003065A4-1021-11E8-A8D5-435154454348"),
                            type: .ascii),

        "003065A4-1022-11E8-A8D5-435154454348": CTBleCharacteristic(name: "serial_number_bike",
                            UUID: CBUUID(string: "003065A4-1022-11E8-A8D5-435154454348"),
                            type: .ascii),

        "003065A4-1023-11E8-A8D5-435154454348": CTBleCharacteristic(name: "serial_number_battery",
                            UUID: CBUUID(string: "003065A4-1023-11E8-A8D5-435154454348"),
                            type: .ascii),

        "003065A4-1024-11E8-A8D5-435154454348": CTBleCharacteristic(name: "bike_software_version",
                            UUID: CBUUID(string: "003065A4-1024-11E8-A8D5-435154454348"),
                            type: .ascii),

        "003065A4-1025-11E8-A8D5-435154454348": CTBleCharacteristic(name: "controller_software_version",
                            UUID: CBUUID(string: "003065A4-1025-11E8-A8D5-435154454348"),
                            type: .ascii),

        "003065A4-1026-11E8-A8D5-435154454348": CTBleCharacteristic(name: "display_software_version",
                            UUID: CBUUID(string: "003065A4-1026-11E8-A8D5-435154454348"),
                            type: .ascii),

        "003065A4-1027-11E8-A8D5-435154454348": CTBleCharacteristic(name: "bike_design_capacity",
                            UUID: CBUUID(string: "003065A4-1027-11E8-A8D5-435154454348"),
                            type: .ascii),

        "003065A4-1028-11E8-A8D5-435154454348": CTBleCharacteristic(name: "wheel_diameter",
                            UUID: CBUUID(string: "003065A4-1028-11E8-A8D5-435154454348"),
                            type: .ascii),

        "003065A4-1029-11E8-A8D5-435154454348": CTBleCharacteristic(name: "imei",
                            UUID: CBUUID(string: "003065A4-1029-11E8-A8D5-435154454348"),
                            type: .ascii)
    ]

    public mutating func handleEvent(peripheral: CBPeripheral, characteristic: CBCharacteristic, type: CTBleEventType) {
        guard var localCharacteristic = characteristics[characteristic.uuid.uuidString] else {
            return
        }

        print("[Static information service] handle \(type) for \(characteristic.uuid.uuidString)")

        localCharacteristic.characteristic = characteristic
        characteristics.updateValue(localCharacteristic, forKey: characteristic.uuid.uuidString)

        switch type {
        case .discover:
            peripheral.setNotifyValue(true, for: characteristic)
        case .notification:
             peripheral.readValue(for: characteristic)
        case .update:
            if let data = characteristic.value {
                let test = String(data: data, encoding: .ascii)
                print(test)
            }
        default:
            break
        }
    }
}
