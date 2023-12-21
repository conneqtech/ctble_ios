//
//  CTDevice.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 30/04/2019.
//

import Foundation
import CoreBluetooth
import RxSwift

public enum CTDeviceType {
    case ck300
}

public class CTDevice: NSObject, CTBlePeripheral {
    public var blePeripheral: CBPeripheral!
    public var peripheralUpdate: PublishSubject = PublishSubject<CTDevice> ()
    public var rssi: NSNumber = 0

    public required init(peripheral: CBPeripheral) {
        super.init()

        self.blePeripheral = peripheral
        self.blePeripheral.delegate = self
    }
}


extension CTDevice: CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        blePeripheral = peripheral
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        blePeripheral = peripheral
    }

    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        blePeripheral = peripheral
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        blePeripheral = peripheral
    }

    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        rssi = RSSI
        peripheralUpdate.onNext(self)
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        blePeripheral = peripheral
    }
}
