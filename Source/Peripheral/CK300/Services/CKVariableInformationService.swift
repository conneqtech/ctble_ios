//
//  CKVariableInformationService.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 18/03/2019.
//

import Foundation
import CoreBluetooth

public class CKVariableInformationService: CTBleServiceProtocol {
    public let UUID: CBUUID = CBUUID(string: "003065A4-1050-11E8-A8D5-435154454348")
    public let name: String = "variable_information"
    public var device: CK300Device!
    
    public var characteristics: [CTBleCharacteristic] = [
        CTBleCharacteristic(name: "bike_information",
                            uuid: CBUUID(string: "003065A4-1051-11E8-A8D5-435154454348"),
                            mask: [
                                CTBleCharacteristicMask(range: Range(0...0),
                                                        type: .int8,
                                                        key: .bikeStatus),
                                CTBleCharacteristicMask(range: Range(1...2),
                                                        type: .uint16,
                                                        key: .bikeSpeed),
                                CTBleCharacteristicMask(range: Range(3...4),
                                                        type: .uint16,
                                                        key: .bikeRange),
                                CTBleCharacteristicMask(range: Range(5...8),
                                                        type: .uint32,
                                                        key: .bikeOdometer),
                                CTBleCharacteristicMask(range: Range(9...12),
                                                        type: .uint32,
                                                        key: .bikeBatterySOC),
                                CTBleCharacteristicMask(range: Range(13...14),
                                                        type: .uint16,
                                                        key: .bikeBatterySOCPercentage),
                                CTBleCharacteristicMask(range: Range(15...15),
                                                        type: .int8,
                                                        key: .bikeSupportMode),
                                CTBleCharacteristicMask(range: Range(16...16),
                                                        type: .int8,
                                                        key: .bikeLightStatus),
                                CTBleCharacteristicMask(range: Range(17...17),
                                                        type: .int8,
                                                        key: .erlLockStatus),
                                CTBleCharacteristicMask(range: Range(18...18),
                                                        type: .int8,
                                                        key: .ecuLockStatus)
            ]),
        CTBleCharacteristic(name: "location_information",
                            uuid: CBUUID(string: "003065A4-1052-11E8-A8D5-435154454348"),
                            mask: [
                                CTBleCharacteristicMask(range: Range(0...3),
                                                        type: .int32,
                                                        key: .gpsLongitude),
                                CTBleCharacteristicMask(range: Range(4...7),
                                                        type: .int32,
                                                        key: .gpsLatitude),
                                CTBleCharacteristicMask(range: Range(8...9),
                                                        type: .int16,
                                                        key: .gpsAltitude),
                                CTBleCharacteristicMask(range: Range(10...10),
                                                        type: .uint8,
                                                        key: .gpsHDOP),
                                CTBleCharacteristicMask(range: Range(11...11),
                                                        type: .uint8,
                                                        key: .gpsSpeed)
            ]),
        CTBleCharacteristic(name: "battery_information",
                            uuid: CBUUID(string: "003065A4-1053-11E8-A8D5-435154454348"),
                            mask: [
                                CTBleCharacteristicMask(range: Range(0...3),
                                                        type: .uint32,
                                                        key: .bikeBatteryFCC),
                                CTBleCharacteristicMask(range: Range(4...5),
                                                        type: .uint16,
                                                        key: .bikeBatteryFCCPercentage),
                                CTBleCharacteristicMask(range: Range(6...7),
                                                        type: .uint16,
                                                        key: .bikeBatteryChargingCycles),
                                CTBleCharacteristicMask(range: Range(8...9),
                                                        type: .uint16,
                                                        key: .bikeBatteryPackVoltage),
                                CTBleCharacteristicMask(range: Range(10...11),
                                                        type: .uint16,
                                                        key: .bikeBatteryTemperature),
                                CTBleCharacteristicMask(range: Range(12...14),
                                                        type: .ascii,
                                                        key: .bikeBatteryErrors),
                                CTBleCharacteristicMask(range: Range(15...15),
                                                        type: .uint8,
                                                        key: .bikeBatteryState),
                                CTBleCharacteristicMask(range: Range(16...17),
                                                        type: .uint16,
                                                        key: .backupBatteryVoltage),
                                CTBleCharacteristicMask(range: Range(18...18),
                                                        type: .uint16,
                                                        key: .backupBatteryPercentage),
                                CTBleCharacteristicMask(range: Range(19...20),
                                                        type: .int16,
                                                        key: .bikeBatteryActualCurrent),
                                
            ]),
        CTBleCharacteristic(name: "motor_information",
                            uuid: CBUUID(string: "003065A4-1054-11E8-A8D5-435154454348"),
                            mask: [
                                CTBleCharacteristicMask(range: Range(0...1),
                                                        type: .uint16,
                                                        key: .bikeActualTorque),
                                CTBleCharacteristicMask(range: Range(2...3),
                                                        type: .uint16,
                                                        key: .bikeWheelSpeed),
                                CTBleCharacteristicMask(range: Range(4...5),
                                                        type: .uint16,
                                                        key: .motorPower),
                                CTBleCharacteristicMask(range: Range(6...8),
                                                        type: .ascii,
                                                        key: .motorErrors),
                                CTBleCharacteristicMask(range: Range(9...10),
                                                        type: .uint16,
                                                        key: .pedalCadence),
                                CTBleCharacteristicMask(range: Range(11...12),
                                                        type: .uint16,
                                                        key: .pedalPower),
                                CTBleCharacteristicMask(range: Range(13...13),
                                                        type: .int8,
                                                        key: .receivedSignalStrength),
            ]),
        CTBleCharacteristic(name: "trip_information",
                            uuid: CBUUID(string: "003065A4-1055-11E8-A8D5-435154454348"),
                            mask: [
                                
            ])
        ]
    
    public func setup(withDevice device: CK300Device) {
        print("🐛 Setting up variableInformation")
        self.device = device
        let service = device.blePeripheral.services?.filter { service in
            service.uuid == self.UUID
        }

        if let service = service, service.count > 0 {
            service[0].characteristics?.forEach { characteristic in
                handleEvent(peripheral: device.blePeripheral, characteristic: characteristic, type: .discover)
            }
        }
    }
    
    
    func handleEvent(peripheral: CBPeripheral, characteristic: CBCharacteristic, type: CTBleEventType) {
        let filter = characteristics.filter { $0.uuid == characteristic.uuid }
        guard let ckCharacteristic = filter.first else {
            return
        }
        
        switch type {
        case .discover:
            peripheral.setNotifyValue(true, for: characteristic)
        case .notification:
            peripheral.readValue(for: characteristic)
        case .update:
            if let data = characteristic.value{
                let mask = ckCharacteristic.mask
                
                mask.forEach { item in
                    let slicedData = data.subdata(in: item.range)
                    switch item.type {
                    case .ascii:
                        if let rawString = String(data: slicedData, encoding: .ascii) {
                            if let cString = rawString.cString(using: .utf8) {
                                device.state[item.key] = String(cString: cString)
                            }
                        }
                    case .uint8:
                        device.state[item.key] = Int(slicedData.to(type: UInt8.self))
                    case .uint16:
                        device.state[item.key] = Int(slicedData.to(type: UInt16.self))
                    case .uint32:
                        device.state[item.key] = Int(slicedData.to(type: UInt32.self))
                    case .int8:
                        device.state[item.key] = Int(slicedData.to(type: Int8.self))
                    case .int16:
                        device.state[item.key] = Int(slicedData.to(type: Int16.self))
                    case .int32:
                        device.state[item.key] = Int(slicedData.to(type: Int32.self))
                    default:
                        break
                    }
                    
                    // Post processing
                    if item.key == .gpsLatitude || item.key == .gpsLongitude {
                        if let value = device.state[item.key] as? Int {
                           device.state[item.key] = Double(value) / 1000000
                        }
                    }
                    
                    if item.key == .bikeSpeed {
                        if let value = device.state[item.key] as? Int {
                            device.state[item.key] = Double(value) / 10
                        }
                    }
                    
                    if item.key == .bikeBatteryPackVoltage {
                        if let value = device.state[item.key] as? Int {
                            device.state[item.key] = Double(value) / 100
                        }
                    }
                    
                    if item.key == .bikeActualTorque {
                        if let value = device.state[item.key] as? Int {
                            device.state[item.key] = Double(value) / 100
                        }
                    }
                }
            }
            device.deviceState.onNext(device.state)
        default:
            break
        }
    }
}
