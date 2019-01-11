//
//  CK300Device.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 10/01/2019.
//

import Foundation
import CoreBluetooth

public enum CK300Characteristic: String {
    case password = "003065A4-1002-11E8-A8D5-435154454348"
    case authenticationStatus = "003065A4-1003-11E8-A8D5-435154454348"
}

public enum CK300Service: String {
    case authentication = "003065A4-1001-11E8-A8D5-435154454348"
}

public class CK300Device: CTBasePeripheral {
    public var peripheral: CBPeripheral!

    public let authenticatedServices: [CBUUID] = [
        CBUUID(string: "003065A4-1020-11E8-A8D5-435154454348"),
        CBUUID(string: "003065A4-1050-11E8-A8D5-435154454348"),
        CBUUID(string: "003065A4-10A0-11E8-A8D5-435154454348"),
        CBUUID(string: "003065A4-10B0-11E8-A8D5-435154454348")
    ]
    
    public var discoveredCharacteristics: [String: CBCharacteristic] = [:]

    public required init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }

    public func login(withPassword password: String) {
        print("== Performing login ==")
        self.peripheral.discoverServices([CBUUID(string: CK300Service.authentication.rawValue)])
    }

    public func discoverCharacteristics(for service: CBService) {

    }

    public func handleDiscoveredCharacteristic(_ characteristic: CBCharacteristic) {
        discoveredCharacteristics[characteristic.uuid.uuidString] = characteristic
        switch characteristic.uuid.uuidString {
        case CK300Characteristic.password.rawValue:
            print("== Found password char")
            peripheral.writeValue("<p&F0hFN?*J*N?lckw_?".data(using: .ascii)!,
                                  for: characteristic,
                                  type: .withResponse)
        case CK300Characteristic.authenticationStatus.rawValue:
            print("== Found authentication status")
        default:
            break
        }
    }

    public func handleCharacteristicUpdate(_ characteristic: CBCharacteristic) {
        switch characteristic.uuid.uuidString {
        case CK300Characteristic.password.rawValue:
            break
        case CK300Characteristic.authenticationStatus.rawValue:
            print("== Update authentication status")
            if let data = characteristic.value {
                print(Int8(bitPattern: data[0]))
            }
        default:
            break
        }
    }

    public func handleCharacteristicWrite(_ characteristic: CBCharacteristic) {
        print(characteristic.uuid.uuidString)
        
        switch characteristic.uuid.uuidString {
        case CK300Characteristic.password.rawValue:
            print("== Wrote password, reading result")
            
            if let authStatusChar = discoveredCharacteristics[CK300Characteristic.authenticationStatus.rawValue] {
                peripheral.readValue(for: authStatusChar)
            }
        default:
            break
        }
    }

    public func handleDiscoveredService(_ service: CBService) {
        switch (service.uuid.uuidString) {
        case CK300Service.authentication.rawValue:
            print("== Discovered auth service")
            self.peripheral.discoverCharacteristics(nil, for: service)
        default:
            print("Unknown service")
            break
        }
    }
}
