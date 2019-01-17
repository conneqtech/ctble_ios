//
//  CTBaseService.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 14/01/2019.
//

import Foundation
import CoreBluetooth

public enum CTBleServiceType {
    case unauthenticated
    case authenticated
    case login
}

public enum CTBleEventType {
    case write
    case read
    case update
    case notification
    case discover
}

public protocol CTDeviceServiceProtocol {
    var name: String { get }
    var UUID: CBUUID { get }
    var type: CTBleServiceType { get }
    var characteristics: [String: CTBleCharacteristic] { get set }

    mutating func handleEvent(peripheral: CBPeripheral, characteristic: CBCharacteristic, type: CTBleEventType)
}
