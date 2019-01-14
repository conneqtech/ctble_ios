//
//  CTCharacteristic.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 14/01/2019.
//

import Foundation
import CoreBluetooth

public enum CTBleCharacteristicPermission {
    case read
    case write
    case notify
}

public enum CTBleCharacteristicType {
    case ascii
    case uint16
    case int16
    case uint8
    case int8
    case int32
    case uint32
    case masked
}

public struct CTBleCharacteristic {
    public var name: String
    public var UUID: CBUUID
    public var type: CTBleCharacteristicType
    public var mask: [CTBleCharacteristicType]
    public var permission: [CTBleCharacteristicPermission]
    public var characteristic: CBCharacteristic?

    public init (name: String,
                 UUID: CBUUID,
                 type: CTBleCharacteristicType,
                 mask: [CTBleCharacteristicType] = [],
                 permission: [CTBleCharacteristicPermission] = [.read]) {
        self.name = name
        self.UUID = UUID
        self.type = type

        if mask.isEmpty {
            self.mask = [self.type]
        } else {
            self.mask = mask
        }

        self.permission = permission
    }
}
