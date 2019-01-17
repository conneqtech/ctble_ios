//
//  CTVariableInformationService.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 14/01/2019.
//

import Foundation
import CoreBluetooth

public struct CKBatteryInformationService: CTBleServiceProtocol {
    public let UUID: CBUUID = CBUUID(string: "003065A4-1050-11E8-A8D5-435154454348")
    public let name: String = "variable_information"
    public let type: CTBleServiceType = .authenticated

    public var characteristics: [String : CTBleCharacteristic] = [
        "003065A4-1053-11E8-A8D5-435154454348": CTBleCharacteristic(name: "battery_information",
                                                                    UUID: CBUUID(string: "003065A4-1053-11E8-A8D5-435154454348"),
                                                                    type: .masked,
                                                                    mask: [.uint8, .uint16],
                                                                    permission: [.read, .notify])
    ]

    public func handleEvent(peripheral: CBPeripheral, characteristic: CBCharacteristic, type: CTBleEventType) {
        guard var localCharacteristic = characteristics[characteristic.uuid.uuidString] else {
            return
        }

        print("[BatIS] handle \(type) for \(characteristic.uuid.uuidString)")

        switch type {
        case .discover:
            peripheral.setNotifyValue(true, for: characteristic)
        case .notification:
            peripheral.readValue(for: characteristic)
        case .update:
            if localCharacteristic.name == "battery_information" {
                if let data = characteristic.value {
                    let fccMahData = data.subdata(in: Range(0...3))
                    let fccPercentageData = data.subdata(in: Range(4...5))
                    let chargingCycleData = data.subdata(in: Range(6...7))
                    let packVoltageData = data.subdata(in: Range(8...9))
                    let temperatureData = data.subdata(in: Range(10...11))
                    let batteryErrorData = data.subdata(in: Range(12...14))
                    let batteryStateData = data[15]

                    let fccMah = fccMahData.withUnsafeBytes {
                        (pointer: UnsafePointer<UInt32>) -> UInt32 in
                        return pointer.pointee
                    }

                    let fccPercentage = fccPercentageData.withUnsafeBytes {
                        (pointer: UnsafePointer<UInt16>) -> UInt16 in
                        return pointer.pointee
                    }

                    let chargingCycles = chargingCycleData.withUnsafeBytes {
                        (pointer: UnsafePointer<UInt16>) -> UInt16 in
                        return pointer.pointee
                    }

                    let packVoltage = packVoltageData.withUnsafeBytes {
                        (pointer: UnsafePointer<UInt16>) -> UInt16 in
                        return pointer.pointee
                    }

                    let temperature = temperatureData.withUnsafeBytes {
                        (pointer: UnsafePointer<UInt16>) -> UInt16 in
                        return pointer.pointee
                    }

                    let batteryError = String(bytes: batteryErrorData, encoding: .ascii)

                    var backupBatteryVoltage: UInt16 = 0
                    if data.count >= 17 {
                        var backupBatteryData = data.subdata(in: Range(16...17))
                        backupBatteryVoltage = backupBatteryData.withUnsafeBytes {
                            (pointer: UnsafePointer<UInt16>) -> UInt16 in
                            return pointer.pointee
                        }
                    }

                    let batteryInformation = CKBatteryInformationData(
                        fccMah: Int(fccMah),
                        fccPercentage: Int(fccPercentage),
                        chargingCycles: Int(chargingCycles),
                        packVoltage: Int(packVoltage),
                        temperature: Int(temperature),
                        errors: batteryError!,
                        state: Int(batteryStateData),
                        backupBatteryVoltage: Int(backupBatteryVoltage))

                    CTVariableInformationService.shared.updateBatteryInformation(batteryInformation)
                }
            }
        default:
            break
        }
    }
}
