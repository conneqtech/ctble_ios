//
//  CK300Device.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 10/01/2019.
//

import Foundation
import CoreBluetooth

public class CK300Device: CTBlePeripheral {
    public var peripheral: CBPeripheral!

    public var services: [String: CTDeviceServiceProtocol] = [
        "authentication": CTDeviceAuthenticationService(),
        "static_information" : CTDeviceStaticInformationService(),
        "location_information": CTDeviceLocationService(),
        "bike_information": CTDeviceBikeInformationService(),
        "battery_information": CTDeviceBatteryInformationService(),
        "motor_information": CTDeviceMotorInformationService()
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
        print("== Fetching static information ==")

        if let service = services["static_information"] {
            self.peripheral.discoverServices([service.UUID])
        }
    }

    public func getBatteryInformation() {
        print("== Fetching battery information ==")

        if let service = services["battery_information"] {
            self.peripheral.discoverServices([service.UUID])
        }
    }

    public func startReportingLocationData() {
        if let service = services["location_information"] {
            self.peripheral.discoverServices([service.UUID])
        }
    }

    public func getBikeInformation() {
        print("== Fetching bike information ==")

        if let service = services["bike_information"] {
            self.peripheral.discoverServices([service.UUID])
        }
    }

    public func discoverCharacteristics(for service: CBService) {

    }

    internal func handleEvent(characteristic: CBCharacteristic, type: CTBleEventType) {
        self.services.keys.forEach { key in
            self.services[key]!.handleEvent(peripheral: peripheral, characteristic: characteristic, type: type)
        }
    }

    public func handleDiscoveredService(_ service: CBService) {
        self.peripheral.discoverCharacteristics(nil, for: service)
    }
}
