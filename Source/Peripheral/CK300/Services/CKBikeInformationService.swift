//
//  CKBikeInformationService.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 14/01/2019.
//

import Foundation
import CoreBluetooth

public struct CKBikeInformationService: CTBleServiceProtocol {
    public let UUID: CBUUID = CBUUID(string: "003065A4-1050-11E8-A8D5-435154454348")
    public let name: String = "variable_information"
    public let type: CTBleServiceType = .authenticated

    public var characteristics: [String : CTBleCharacteristic] = [
        "003065A4-1051-11E8-A8D5-435154454348": CTBleCharacteristic(name: "bike_information",
                                                                    UUID: CBUUID(string: "003065A4-1051-11E8-A8D5-435154454348"),
                                                                    type: .masked,
                                                                    mask: [.uint8, .uint16],
                                                                    permission: [.read, .notify])
        ]

    public func handleEvent(peripheral: CBPeripheral, characteristic: CBCharacteristic, type: CTBleEventType) {
        guard var localCharacteristic = characteristics[characteristic.uuid.uuidString] else {
            return
        }

        print("[BIS] handle \(type) for \(characteristic.uuid.uuidString)")

        switch type {
        case .discover:
            peripheral.setNotifyValue(true, for: characteristic)
        case .notification:
            peripheral.readValue(for: characteristic)
        case .update:
            if localCharacteristic.name == "bike_information" {
                if let data = characteristic.value {
                    let bikeStatusData = data[0]
                    let speedData = data.subdata(in: Range(1...2))
                    let rangeData = data.subdata(in: Range(3...4))
                    let odometerData = data.subdata(in: Range(5...8))
                    let bikeBatterySOCData = data.subdata(in: Range(9...12))
                    let bikeBatterySOCPercentData = data.subdata(in: Range(13...14))
                    let supportModeData = data[15]

                    let speed = speedData.withUnsafeBytes {
                        (pointer: UnsafePointer<UInt16>) -> UInt16 in
                        return pointer.pointee
                    }

                    let range = rangeData.withUnsafeBytes {
                        (pointer: UnsafePointer<UInt16>) -> UInt16 in
                        return pointer.pointee
                    }

                    let odometer = odometerData.withUnsafeBytes {
                        (pointer: UnsafePointer<UInt32>) -> UInt32 in
                        return pointer.pointee
                    }

                    let bikeBatterySOC = bikeBatterySOCData.withUnsafeBytes {
                        (pointer: UnsafePointer<UInt16>) -> UInt16 in
                        return pointer.pointee
                    }

                    let bikeBatterySOCPercent = bikeBatterySOCPercentData.withUnsafeBytes {
                        (pointer: UnsafePointer<UInt16>) -> UInt16 in
                        return pointer.pointee
                    }

                    var lightStatusData: UInt8 = 0
                    if data.count == 17 {
                        lightStatusData = data[16]
                    }

                    let bikeInformation = CKBikeInformationData(bikeStatus: Int(bikeStatusData),
                                                speed: Int(speed),
                                                range: Int(range),
                                                odometer: Int(odometer),
                                                bikeBatterySOC: Int(bikeBatterySOC),
                                                bikeBatterySOCPercentage: Int(bikeBatterySOCPercent),
                                                supportMode: Int(supportModeData),
                                                lightStatus: Int(lightStatusData)
                        )

                    CTVariableInformationService.shared.updateBikeInformation(bikeInformation)
                }
            }
        default:
            break
        }
    }
}
