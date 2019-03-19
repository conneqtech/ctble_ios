//
//  CKStaticInformationService.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 14/01/2019.
//

import Foundation
import CoreBluetooth

public class CKStaticInformationService: CTBleServiceProtocol {
    public let UUID: CBUUID = CBUUID(string: "003065A4-1020-11E8-A8D5-435154454348")
    public let name: String = "static_information"
    public var device: CK300Device!

    public var characteristics: [CTBleCharacteristic] = [
        CTBleCharacteristic(name: "bike_type",
                            uuid: CBUUID(string: "003065A4-1021-11E8-A8D5-435154454348"),
                            mask: [
                                CTBleCharacteristicMask(range: Range(0...14),
                                                        type: .ascii,
                                                        key: .bikeType)
                            ]),
        CTBleCharacteristic(name: "serial_number_bike",
                            uuid: CBUUID(string: "003065A4-1022-11E8-A8D5-435154454348"),
                            mask: [
                                CTBleCharacteristicMask(range: Range(0...29),
                                                        type: .ascii,
                                                        key: .bikeSerialNumber)
            ]),

        CTBleCharacteristic(name: "serial_number_battery",
                            uuid: CBUUID(string: "003065A4-1023-11E8-A8D5-435154454348"),
                            mask: [
                                CTBleCharacteristicMask(range: Range(0...29),
                                                        type: .ascii,
                                                        key: .batterySerialNumber)
            ]),

        CTBleCharacteristic(name: "bike_software_version",
                            uuid: CBUUID(string: "003065A4-1024-11E8-A8D5-435154454348"),
                            mask: [
                                CTBleCharacteristicMask(range: Range(0...14),
                                                        type: .ascii,
                                                        key: .bikeSoftwareVersion)
            ]),

        CTBleCharacteristic(name: "controller_software_version",
                            uuid: CBUUID(string: "003065A4-1025-11E8-A8D5-435154454348"),
                            mask: [
                                CTBleCharacteristicMask(range: Range(0...14),
                                                        type: .ascii,
                                                        key: .controllerSoftwareVersion)
            ]),

        CTBleCharacteristic(name: "display_software_version",
                            uuid: CBUUID(string: "003065A4-1026-11E8-A8D5-435154454348"),
                            mask: [
                                CTBleCharacteristicMask(range: Range(0...14),
                                                        type: .ascii,
                                                        key: .displaySoftwareVersion)
            ]),

        CTBleCharacteristic(name: "bike_design_capacity",
                            uuid: CBUUID(string: "003065A4-1027-11E8-A8D5-435154454348"),
                            mask: [
                                CTBleCharacteristicMask(range: Range(0...1),
                                                        type: .uint16,
                                                        key: .bikeDesignCapacity)
            ]),

        CTBleCharacteristic(name: "wheel_diameter",
                            uuid: CBUUID(string: "003065A4-1028-11E8-A8D5-435154454348"),
                            mask: [
                                CTBleCharacteristicMask(range: Range(0...1),
                                                        type: .uint16,
                                                        key: .wheelDiameter)
            ]),

        CTBleCharacteristic(name: "ble_version",
                            uuid: CBUUID(string: "003065A4-1029-11E8-A8D5-435154454348"),
                            mask: [
                                CTBleCharacteristicMask(range: Range(0...14),
                                                        type: .ascii,
                                                        key: .bleVersion)
            ]),
        CTBleCharacteristic(name: "air_version",
                            uuid: CBUUID(string: "003065A4-1030-11E8-A8D5-435154454348"),
                            mask: [
                                CTBleCharacteristicMask(range: Range(0...14),
                                                        type: .ascii,
                                                        key: .airVersion)
            ])
    ]
    
    public func setup(withDevice device: CK300Device) {
        print("🐛 Setting up staticInformation")
        self.device = device
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
                }
            }
            device.deviceState.onNext(device.state)
        default:
            break
        }
    }
}
