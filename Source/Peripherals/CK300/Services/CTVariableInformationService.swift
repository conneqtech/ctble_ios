//
//  CTVariableInformationService.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 14/01/2019.
//

import Foundation
import CoreBluetooth

public struct CTVariableInformationService: CTBleServiceProtocol {
    public let UUID: CBUUID = CBUUID(string: "003065A4-1050-11E8-A8D5-435154454348")
    public let name: String = "variable_information"
    public let type: CTBleServiceType = .authenticated

    public var characteristics: [String : CTBleCharacteristic] = [
        "003065A4-1052-11E8-A8D5-435154454348": CTBleCharacteristic(name: "location_information",
                                                                    UUID: CBUUID(string: "003065A4-1052-11E8-A8D5-435154454348"),
                                                                    type: .masked,
                                                                    mask: [.ascii, .int16],
                                                                    permission: [.read, .notify])
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
            if let data = characteristic.value {
                let latData = data.subdata(in: Range(0...3))
                let lonData = data.subdata(in: Range(4...7))
                let altData = data.subdata(in: Range(8...9))

                let latInt = latData.withUnsafeBytes {
                    (pointer: UnsafePointer<Int32>) -> Int32 in
                    return pointer.pointee
                }

                let lonInt = lonData.withUnsafeBytes {
                    (pointer: UnsafePointer<Int32>) -> Int32 in
                    return pointer.pointee
                }
                
                let altInt = altData.withUnsafeBytes {
                    (pointer: UnsafePointer<Int16>) -> Int16 in
                    return pointer.pointee
                }


                print("Lat: \(Double(latInt) / 1000000)")
                print("Lon: \(Double(lonInt) / 1000000)")
                print("Alt: \(altInt)")
            }
        default:
            break
        }
    }
}
