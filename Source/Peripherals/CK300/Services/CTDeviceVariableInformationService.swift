//
//  CTVariableInformationService.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 14/01/2019.
//

import Foundation
import CoreBluetooth

public struct CTDeviceVariableInformationService: CTDeviceServiceProtocol {
    public let UUID: CBUUID = CBUUID(string: "003065A4-1050-11E8-A8D5-435154454348")
    public let name: String = "variable_information"
    public let type: CTBleServiceType = .authenticated

    public var characteristics: [String : CTBleCharacteristic] = [
        "003065A4-1051-11E8-A8D5-435154454348": CTBleCharacteristic(name: "bike_information",
                                                                    UUID: CBUUID(string: "003065A4-1051-11E8-A8D5-435154454348"),
                                                                    type: .masked,
                                                                    mask: [.uint8, .uint16],
                                                                    permission: [.read, .notify]),
    ]

    public func handleEvent(peripheral: CBPeripheral, characteristic: CBCharacteristic, type: CTBleEventType) {
        guard var localCharacteristic = characteristics[characteristic.uuid.uuidString] else {
            return
        }

        print("[Variable information service] handle \(type) for \(characteristic.uuid.uuidString)")

        switch type {
        case .discover:
            peripheral.setNotifyValue(true, for: characteristic)
        case .notification:
            peripheral.readValue(for: characteristic)
        case .update:
            if localCharacteristic.name == "bike_information" {
                 if let data = characteristic.value {
                    print("BS: \(data[0])")
                }
            }
        default:
            break
        }
    }
}
