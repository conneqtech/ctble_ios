//
//  CTBasePerhiperal.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 10/01/2019.
//

import Foundation
import CoreBluetooth

public protocol CTBasePeripheral {
    var peripheral: CBPeripheral! { get set}
}
