//
//  CTBleManagerDelegate.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 29/05/2018.
//  Copyright © 2018 Conneqtech. All rights reserved.
//

import CoreBluetooth

@objc public protocol CTBleManagerDelegate {

    /**
     The callback function when peripheral has been found.
     
     - parameter peripheral:        The peripheral has been found.
     - parameter advertisementData: The advertisement data.
     - parameter RSSI:              The signal strength.
     */
    @objc optional func didDiscoverPeripheral(_ peripheral: CBPeripheral, advertisementData: [String : Any], RSSI: NSNumber)

    @objc optional func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)

    @objc optional func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?)

    @objc optional func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?)

    @objc optional func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)

    @objc optional func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)
}
