//
//  CK300Device.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 10/01/2019.
//

import Foundation
import CoreBluetooth

public class CK300Device: CTBasePeripheral {
    public var peripheral: CBPeripheral!

    public var services: [String: CTBleServiceProtocol] = [
        "authentication": CTAuthenticationService(),
        "static_information" : CTStaticInformationService(),
        "variable_information": CTVariableInformationService()
    ]

    public var UUIDList: [String: String] = [:]

    public var discoveredCharacteristics: [String: CBCharacteristic] = [:]

    public required init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        self.UUIDList = self.buildUUIDList()
    }

    public func buildUUIDList() -> [String: String] {
        var uuidList: [String: String] = [:]
        services.forEach { _, service in
            uuidList[service.UUID.uuidString] = service.name
            service.characteristics.forEach { key, characteristic in
                uuidList[key] = "\(service.name)|\(characteristic.name)"
            }
        }

        return uuidList
    }

    public func login(withPassword password: String) {
        print("== Performing login ==")

        if let service = services["authentication"] {
            self.peripheral.discoverServices([service.UUID])
        }
    }

    public func getStaticInformation() {
        getVariableInformaiton()
        return

        print("== Fetching static information ==")

        if let service = services["static_information"] {
            self.peripheral.discoverServices([service.UUID])
        }
    }

    public func getVariableInformaiton() {
        print("== Fetching variable information ==")

        if let service = services["variable_information"] {
            self.peripheral.discoverServices([service.UUID])
        }
    }

    public func discoverCharacteristics(for service: CBService) {

    }

    public func handleEvent(characteristic: CBCharacteristic, type: CTBleEventType) {
        self.services.keys.forEach { key in
            self.services[key]!.handleEvent(peripheral: peripheral, characteristic: characteristic, type: type)
        }
    }

    public func handleDiscoveredService(_ service: CBService) {
        guard  let foundItem = UUIDList[service.uuid.uuidString] else {
            return
        }

        switch foundItem {
        case "authentication":
            print("== Discovered auth service")
            self.peripheral.discoverCharacteristics(nil, for: service)
        case "static_information":
            print("== Discovered static information service")
            self.peripheral.discoverCharacteristics(nil, for: service)
        case "variable_information":
            print("== Discovered static information service")
            self.peripheral.discoverCharacteristics(nil, for: service)
        default:
            print("⚠️ This service will not be handled for this device")
        }
    }
}
