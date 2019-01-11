//
//  CTBleManagerDelegate.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 29/05/2018.
//  Copyright © 2018 Conneqtech. All rights reserved.
//

import CoreBluetooth

public protocol CTBleManagerDelegate: class {
    func didDiscover(_ device: CK300Device)

    func didConnect(_ device: CK300Device)

    func didFailToConnect(_ device: CK300Device)
}
