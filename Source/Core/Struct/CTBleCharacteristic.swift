//
//  CTCharacteristic.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 14/01/2019.
//

import Foundation
import CoreBluetooth

public struct CTBleCharacteristic {
    public var name: String
    public var UUID: CBUUID
    public var mask: [CTBleCharacteristicMask]
    public var characteristic: CBCharacteristic?

    public init (name: String,
                 UUID: CBUUID,
                 mask: [CTBleCharacteristicMask] = []) {
        self.name = name
        self.UUID = UUID
        self.mask = mask
    }
}
