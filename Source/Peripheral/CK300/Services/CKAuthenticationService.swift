//
//  CKAutenticationService.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 11/01/2019.
//

import Foundation
import CoreBluetooth

public class CKAuthenticationService: NSObject {
    public let uuid: CBUUID = CBUUID(string: "003065A4-1001-11E8-A8D5-435154454348")
    public let name: String = "authentication"
    
    public var maxRetries = 3
    public var device: CK300Device!
    public var password = ""
    
    public var authService: CBService?
    public var passwordCharacteristic: CBCharacteristic?
    public var authenticationStatusCharacteristic: CBCharacteristic?
    
    public var notifyingChars = 0

    public var characteristics: [CTBleCharacteristic] = [
        CTBleCharacteristic(name: "password",
                            uuid: CBUUID(string: "003065A4-1002-11E8-A8D5-435154454348"),
                            mask: []),
        CTBleCharacteristic(name: "authentication_status",
                            uuid: CBUUID(string: "003065A4-1003-11E8-A8D5-435154454348"),
                            mask: [])
    ]

    public func startAuthentication(withPassword password: String, andDevice device: CK300Device) {
        self.device = device
        self.password = password
        self.notifyingChars = 0
        let filterResult = self.device.blePeripheral.services?.filter { service in
            service.uuid.uuidString == "003065A4-1001-11E8-A8D5-435154454348"
        }

        print("GOING PLACES")
        
        if let authService = filterResult?.first {
            print("HAS AUTH")
            self.authService = authService

            authService.characteristics?.forEach { characteristic in
                print("GO WILDE")
                
                //Password char
                if characteristic.uuid.uuidString == "003065A4-1002-11E8-A8D5-435154454348" {
                    self.passwordCharacteristic = characteristic
                }
                
                // Status char
                if characteristic.uuid.uuidString == "003065A4-1003-11E8-A8D5-435154454348" {
                    self.authenticationStatusCharacteristic = characteristic
                    self.device.blePeripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }
    
    func handleEvent(peripheral: CBPeripheral, characteristic: CBCharacteristic, type: CTBleEventType) {
        let filterResult = self.characteristics.filter { element in
            element.uuid == characteristic.uuid
        }
        
        guard let localCharacteristic = filterResult.first else {
            return
        }
        
        if localCharacteristic.name == "authentication_status" && type == .notification {
            print("👂 Authentication status is listening")
            
            if let passwordCharacteristic = self.passwordCharacteristic {
                self.device.blePeripheral.writeValue(
                    self.password.data(using: .ascii)!,
                    for: passwordCharacteristic,
                    type: .withResponse)
            }
        }
        
        if type == .write {
            print("🖋 Writing the password to the device")
        }
        
        if localCharacteristic.name == "authentication_status" && type == .update {
            if let data = characteristic.value {
                let state = Int8(bitPattern: data[0])
                if Int(state) == 0 {
                    print("🔑 We are unlocked now")
                } else {
                    print("🚫 Access denied")
                }
                
                CTAuthenticationService.shared.updateAuthenticationStatus(Int(state))
            }
        }
    }
}
