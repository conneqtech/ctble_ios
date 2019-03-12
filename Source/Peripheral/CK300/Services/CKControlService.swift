//
//  CKControlService.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 11/03/2019.
//

import Foundation
import CoreBluetooth

public struct CKControlService: CTBleServiceProtocol {
    public let UUID: CBUUID = CBUUID(string: "003065A4-10A0-11E8-A8D5-435154454348")
    public let name: String = "control"
    public let type: CTBleServiceType = .authenticated
    
    public var characteristics: [String : CTBleCharacteristic] = [
        "003065A4-10A1-11E8-A8D5-435154454348": CTBleCharacteristic(name: "bike_onoff",
                                                                    UUID: CBUUID(string: "003065A4-10A1-11E8-A8D5-435154454348"),
                                                                    type: .uint8,
                                                                    mask: [],
                                                                    permission: [.read, .write]),
        "003065A4-10A2-11E8-A8D5-435154454348": CTBleCharacteristic(name: "lights_onoff",
                                                                    UUID: CBUUID(string: "003065A4-10A2-11E8-A8D5-435154454348"),
                                                                    type: .uint8,
                                                                    mask: [],
                                                                    permission: [.read, .write]),
        "003065A4-10A3-11E8-A8D5-435154454348": CTBleCharacteristic(name: "ecu_lock_onoff",
                                                                    UUID: CBUUID(string: "003065A4-10A3-11E8-A8D5-435154454348"),
                                                                    type: .uint8,
                                                                    mask: [],
                                                                    permission: [.read, .write]),
        "003065A4-10A14-11E8-A8D5-435154454348": CTBleCharacteristic(name: "erl_lock_onoff",
                                                                    UUID: CBUUID(string: "003065A4-10A4-11E8-A8D5-435154454348"),
                                                                    type: .uint8,
                                                                    mask: [],
                                                                    permission: [.read, .write]),
        "003065A4-10A5-11E8-A8D5-435154454348": CTBleCharacteristic(name: "support_mode",
                                                                    UUID: CBUUID(string: "003065A4-10A5-11E8-A8D5-435154454348"),
                                                                    type: .uint8,
                                                                    mask: [],
                                                                    permission: [.read, .write]),
        "003065A4-10A6-11E8-A8D5-435154454348": CTBleCharacteristic(name: "digital_io_onoff",
                                                                    UUID: CBUUID(string: "003065A4-10A6-11E8-A8D5-435154454348"),
                                                                    type: .uint8,
                                                                    mask: [],
                                                                    permission: [.read, .write])
    ]
    
    public mutating func handleEvent(peripheral: CBPeripheral, characteristic: CBCharacteristic, type: CTBleEventType) {
        
        guard var localCharacteristic = characteristics[characteristic.uuid.uuidString] else {
            return
        }
        
        localCharacteristic.characteristic = characteristic
        characteristics.updateValue(localCharacteristic, forKey: characteristic.uuid.uuidString)
        
        print("[Control service] handle \(type) for \(characteristic.uuid.uuidString)")
        
        switch type {
        case .discover:
            peripheral.setNotifyValue(true, for: characteristic)
        case .notification:
            peripheral.readValue(for: characteristic)
        case .update:
            if let data = characteristic.value {
                print("Char: \(localCharacteristic.name)")
                print("Value: \(Int(data[0]))")
                
                var command:UInt8 = 0
                var data = Data(bytes: &command, count: MemoryLayout<UInt8>.size)
                
                peripheral.writeValue(data, for: localCharacteristic.characteristic!, type: .withResponse)
//                
//                if localCharacteristic.name == "bike_onoff" {
//                    var command:UInt8 = 1
//                    var data = Data(bytes: &command, count: MemoryLayout<UInt8>.size)
//                    
//                    peripheral.writeValue(data, for: localCharacteristic.characteristic!, type: .withResponse)
//                }
//                
//                if localCharacteristic.name == "lights_onoff" {
//                    var command:UInt8 = 0
//                    var data = Data(bytes: &command, count: MemoryLayout<UInt8>.size)
//                    
//                    peripheral.writeValue(data, for: localCharacteristic.characteristic!, type: .withResponse)
//                }

            }
            
            break
        default:
            break
        }
    }
}
