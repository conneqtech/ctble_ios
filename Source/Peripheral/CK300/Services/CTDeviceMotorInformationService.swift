//
//  CTVariableInformationService.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 14/01/2019.
//

import Foundation
import CoreBluetooth

public struct CTMotorInformation {
    public var actualTorque: Int
    public var wheelSpeed: Int
    public var motorPower: Int
    public var motorError: String
    public var pedalCadence: Int
    public var pedalPower: Int
    public var receivedSignalStrength: Int
}

public struct CTDeviceMotorInformationService: CTBleServiceProtocol {
    public let UUID: CBUUID = CBUUID(string: "003065A4-1050-11E8-A8D5-435154454348")
    public let name: String = "variable_information"
    public let type: CTBleServiceType = .authenticated

    public var characteristics: [String : CTBleCharacteristic] = [
        "003065A4-1054-11E8-A8D5-435154454348": CTBleCharacteristic(name: "motor_information",
                                                                    UUID: CBUUID(string: "003065A4-1054-11E8-A8D5-435154454348"),
                                                                    type: .masked,
                                                                    mask: [.uint8, .uint16],
                                                                    permission: [.read, .notify])
    ]

    public func handleEvent(peripheral: CBPeripheral, characteristic: CBCharacteristic, type: CTBleEventType) {
        guard var localCharacteristic = characteristics[characteristic.uuid.uuidString] else {
            return
        }

        print("[MIS] handle \(type) for \(characteristic.uuid.uuidString)")

        switch type {
        case .discover:
            peripheral.setNotifyValue(true, for: characteristic)
        case .notification:
            peripheral.readValue(for: characteristic)
        case .update:
            if localCharacteristic.name == "motor_information" {
                if let data = characteristic.value {
                    let actualTorqueData = data.subdata(in: Range(0...1))
                    let wheelSpeedData = data.subdata(in: Range(2...3))
                    let motorPowerData = data.subdata(in: Range(4...5))
                    let motorErrorData = data.subdata(in: Range(6...8))
                    let pedalCadenceData = data.subdata(in: Range(9...10))
                    let pedalPowerData = data.subdata(in: Range(11...12))

                    let receivedSignalStrengthData = data[13]

                    let actualTorque = actualTorqueData.withUnsafeBytes {
                        (pointer: UnsafePointer<UInt16>) -> UInt16 in
                        return pointer.pointee
                    }

                    let wheelSpeed = wheelSpeedData.withUnsafeBytes {
                        (pointer: UnsafePointer<UInt16>) -> UInt16 in
                        return pointer.pointee
                    }

                    let motorPower = motorPowerData.withUnsafeBytes {
                        (pointer: UnsafePointer<UInt16>) -> UInt16 in
                        return pointer.pointee
                    }

                    let motorError = String(bytes: motorErrorData, encoding: .ascii)

                    let pedalCadence = pedalCadenceData.withUnsafeBytes {
                        (pointer: UnsafePointer<UInt16>) -> UInt16 in
                        return pointer.pointee
                    }

                    let pedalPower = pedalPowerData.withUnsafeBytes {
                        (pointer: UnsafePointer<UInt16>) -> UInt16 in
                        return pointer.pointee
                    }

                    let motorInformation = CTMotorInformation(
                        actualTorque: Int(actualTorque),
                        wheelSpeed: Int(wheelSpeed),
                        motorPower: Int(motorPower),
                        motorError: motorError!,
                        pedalCadence: Int(pedalCadence),
                        pedalPower: Int(pedalPower),
                        receivedSignalStrength: Int(receivedSignalStrengthData))

                    CTVariableInformationService.shared.updateMotorInformation(motorInformation)
                }
            }
        default:
            break
        }
    }
}
