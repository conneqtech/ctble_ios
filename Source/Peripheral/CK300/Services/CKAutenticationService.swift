//
//  CKAutenticationService.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 11/01/2019.
//

import Foundation
import CoreBluetooth

public struct CKAuthenticationService: CTBleServiceProtocol {
    public let UUID: CBUUID = CBUUID(string: "003065A4-1001-11E8-A8D5-435154454348")
    public let name: String = "authentication"
    public let type: CTBleServiceType = .login

    public var characteristics: [String: CTBleCharacteristic] = [
        "003065A4-1002-11E8-A8D5-435154454348": CTBleCharacteristic(name: "password",
                            UUID: CBUUID(string: "003065A4-1002-11E8-A8D5-435154454348"),
                            type: .ascii,
                            mask: [],
                            permission: [.write]),
        "003065A4-1003-11E8-A8D5-435154454348": CTBleCharacteristic(name: "authentication_status",
                            UUID: CBUUID(string: "003065A4-1003-11E8-A8D5-435154454348"),
                            type: .int8,
                            mask: [],
                            permission: [.read, .notify])
    ]

    public mutating func handleEvent(peripheral: CBPeripheral, characteristic: CBCharacteristic, type: CTBleEventType) {
        guard var localCharacteristic = characteristics[characteristic.uuid.uuidString] else {
            return
        }

//        print("[Authentication service] handle \(type) for \(characteristic.uuid.uuidString)")

        localCharacteristic.characteristic = characteristic
        characteristics.updateValue(localCharacteristic, forKey: characteristic.uuid.uuidString)

        switch type {
        case .discover:
            if localCharacteristic.name == "password" {
                guard let password = CTBleManager.shared.connectedDevice?.password else {
                    print("⚠️ Password not set before performing login.")
                    return
                }
                
                self.authenticate(peripheral, password)
            }
        case .write:
            if localCharacteristic.name == "password" {
                let authStatusChar = characteristics["003065A4-1003-11E8-A8D5-435154454348"]?.characteristic
                peripheral.setNotifyValue(true, for: authStatusChar!)
            }
        case .notification:
            if localCharacteristic.name == "authentication_status" {
                peripheral.readValue(for: localCharacteristic.characteristic!)
            }
        case .update:
            if localCharacteristic.name == "authentication_status" {
                
                guard let password = CTBleManager.shared.connectedDevice?.password else {
                    print("⚠️ Password not set before performing login.")
                    return
                }
                
                if let char = localCharacteristic.characteristic, let data = char.value {
                    let state = Int8(bitPattern: data[0])
                    CTAuthenticationService.shared.updateAuthenticationStatus(Int(state))
                }
            }
        default:
            break
        }
    }
    
    func authenticate(_ peripheral: CBPeripheral, _ password: String) {
        if let passwordChar = characteristics["003065A4-1002-11E8-A8D5-435154454348"]?.characteristic {
            peripheral.writeValue(password.data(using: .ascii)!, for: passwordChar, type: .withResponse)
        }
    }
}
