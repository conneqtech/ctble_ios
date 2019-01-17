//
//  CTBlePeripheral.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 17/01/2019.
//

import Foundation
import CoreBluetooth

public protocol CTBlePeripheral {
    var peripheral: CBPeripheral! { get set}
}
