//
//  CTBaseService.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 14/01/2019.
//

import Foundation
import CoreBluetooth

public protocol CTBleServiceProtocol {
    var name: String { get }
    var UUID: CBUUID { get }
    var type: CTBleServiceType { get }
    var characteristics: [String: CTBleCharacteristic] { get set }

    mutating func handleEvent(peripheral: CBPeripheral, characteristic: CBCharacteristic, type: CTBleEventType)
}
