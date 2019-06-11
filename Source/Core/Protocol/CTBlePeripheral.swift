//
//  CTBlePeripheral.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 17/01/2019.
//

import Foundation
import CoreBluetooth

public protocol CTBlePeripheral {
    var blePeripheral: CBPeripheral! { get set}

    func handleEvent(characteristic: CBCharacteristic, type: CTBleEventType)

    func handleDiscovered(services: [CBService])
    func handleDiscovered(characteristics: [CBCharacteristic], forService service: CBService)
}
