//
//  CKFirmwareUpdateService.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 23/10/2019.
//

import Foundation
import CoreBluetooth

public class CKFirmwareUpdateService: NSObject {
    public let uuid: CBUUID = CBUUID(string: "003065A4-10B0-11E8-A8D5-435154454348")
    public let name: String = "firmware-update"

    public var maxRetries = 3
    public var device: CK300Device!

    public var statusCharacteristic: CBCharacteristic?
    public var updateWriteCharacteristic: CBCharacteristic?

    public var notifyingChars = 0

    public var characteristics: [CTBleCharacteristic] = [
        CTBleCharacteristic(name: "status",
                            uuid: CBUUID(string: "003065A4-10B1-11E8-A8D5-435154454348"),
                            mask: []),
        CTBleCharacteristic(name: "write",
                            uuid: CBUUID(string: "003065A4-10B2-11E8-A8D5-435154454348"),
                            mask: [])
    ]

    public func atartFirmwareUpdate(withDevice device: CK300Device) {
        self.device = device
        self.notifyingChars = 0

        let filterResult = self.device.blePeripheral.services?.filter { service in
            service.uuid.uuidString == "003065A4-10B0-11E8-A8D5-435154454348"
        }

        if let firmwareService = filterResult?.first {
            print("HAVE!")

            firmwareService.characteristics?.forEach { characteristic in
                if characteristic.uuid.uuidString == "003065A4-10B1-11E8-A8D5-435154454348" {
                    self.statusCharacteristic = characteristic
                    self.device.blePeripheral.setNotifyValue(true, for: characteristic)
                }

                if characteristic.uuid.uuidString == "003065A4-10B2-11E8-A8D5-435154454348" {
                    self.updateWriteCharacteristic = characteristic
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

        if localCharacteristic.name == "status" && type == .notification {
            CTFirmwareUpdateService.shared.updateFirmwareUpdateStatus("👂 Status char is notifying us")
            notifyingChars += 1
        }

        if localCharacteristic.name == "write" && type == .notification {
            CTFirmwareUpdateService.shared.updateFirmwareUpdateStatus("👂 Write char is notifying us")
            notifyingChars += 1
        }

        if notifyingChars == 2 {
            notifyingChars += 1
            CTFirmwareUpdateService.shared.updateFirmwareUpdateStatus("✒️ Writing update unlock")
            print("Writing unlock")

            var command:Int8 = Int8(1)
            let data = Data(bytes: &command, count: MemoryLayout<Int8>.size)
            self.device.blePeripheral.writeValue(data, for: self.updateWriteCharacteristic!, type: .withResponse)
        }

        if type == .update && localCharacteristic.name == "status" {
            if let data = characteristic.value {
                let state = data.to(type: UInt16.self)
                CTFirmwareUpdateService.shared.updateFirmwareUpdateStatus("🆙 Status: \(state)")
                let intState = Int(state)
                if intState == 100 {
                    print("WRITE update_packet")
                    CTFirmwareUpdateService.shared.updateFirmwareUpdateStatus("✒️ Writing firmware info")
                    var cmd = "531224,53122,1".data(using: .ascii)!
                    self.device.blePeripheral.writeValue(cmd, for: self.updateWriteCharacteristic!, type: .withResponse)
                }
            }
        }
    }
}
