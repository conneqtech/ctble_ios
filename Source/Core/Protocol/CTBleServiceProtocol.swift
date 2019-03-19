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
    var characteristics: [CTBleCharacteristic] { get set }

    func setup(withDevice device: CK300Device)
    
    mutating func handleEvent(peripheral: CBPeripheral, characteristic: CBCharacteristic, type: CTBleEventType)
}
