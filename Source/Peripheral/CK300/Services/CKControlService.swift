//
//  CKControlService.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 11/03/2019.
//

import Foundation
import CoreBluetooth

public class CKControlService: CTBleServiceProtocol {
    public let UUID: CBUUID = CBUUID(string: "003065A4-10A0-11E8-A8D5-435154454348")
    public let name: String = "control"
    
    public var characteristics: [CTBleCharacteristic] = []
    
    public func setup(withDevice device: CK300Device) {
        // dd
    }
    
    func handleEvent(peripheral: CBPeripheral, characteristic: CBCharacteristic, type: CTBleEventType) {
        let localFilteredCharacteristic = self.characteristics.filter { element in
            element.uuid == characteristic.uuid
        }
        
        if localFilteredCharacteristic.count == 0 {
            return
        }

        print("[Control service] handle \(type) for \(characteristic.uuid.uuidString)")
        
        switch type {
        case .discover:
            peripheral.setNotifyValue(true, for: characteristic)
        case .notification:
            peripheral.readValue(for: characteristic)
        default:
            break
        }
    }
}
