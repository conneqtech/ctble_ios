//
//  CTBleManagerDelegate.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 29/05/2018.
//  Copyright © 2018 Conneqtech. All rights reserved.
//

import CoreBluetooth

public protocol CTBleManagerDelegate: class {
    func didDiscover(_ device: CTDevice)

    func didConnect(_ device: CTDevice)

    func didDisconnect(_ device: CTDevice)

    func didFailToConnect(_ device: CTDevice)
}
