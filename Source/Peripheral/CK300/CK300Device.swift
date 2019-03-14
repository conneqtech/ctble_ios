//
//  CK300Device.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 10/01/2019.
//

import Foundation
import CoreBluetooth
import RxSwift

public enum CKAuthenticationState: Int {
    case unauthenticated = -1
    case authenticated = 0
}

public enum CK300Service {
    case authentication
    case staticInfomation
    case locationInformation
    case bikeInformation
    case batteryInformation
    case motorInformation
}

public class CK300Device: CTBlePeripheral {
    public var peripheral: CBPeripheral!

    public var dataServices: [CK300Service: CTBleServiceProtocol] = [
        .authentication         :   CKAuthenticationService(),
        .staticInfomation       :   CKStaticInformationService(),
        .locationInformation    :   CKLocationService(),
        .bikeInformation        :   CKBikeInformationService(),
        .batteryInformation     :   CKBatteryInformationService(),
        .motorInformation       :   CKMotorInformationService()
    ]
    
    
    public var services: [CBService] = []
    
    public var password = ""

    public var UUIDList: [String: String] = [:]

    public var discoveredCharacteristics: [String: CBCharacteristic] = [:]

    public required init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        self.peripheral.discoverServices(nil)
    }
    
    public func startReportingLocationData() {
        if let service = dataServices[.locationInformation] {
            self.peripheral.discoverServices([service.UUID])
        }
    }
    
    internal func handleEvent(characteristic: CBCharacteristic, type: CTBleEventType) {
        self.dataServices.keys.forEach { key in
            self.dataServices[key]!.handleEvent(peripheral: peripheral, characteristic: characteristic, type: type)
        }
    }
}

// MARK: Data
public extension CK300Device {
    
    public func getData(withServiceType type: CK300Service) {
        if let service = dataServices[type] {
            print("⚡️ Service `\(type)` is being fetched")
            self.peripheral.discoverServices([service.UUID])
        } else {
            print("⚠️ Service `\(type)` is not implemented")
        }
    }
}

// MARK: Handlers
public extension CK300Device {
    public func handleDiscovered(characteristics: [CBCharacteristic]) {
        characteristics.forEach { characteristic in
            self.handleDiscovered(characteristic: characteristic)
        }
    }
    
    public func handleDiscovered(characteristic: CBCharacteristic) {
        self.dataServices.keys.forEach { key in
            self.dataServices[key]!.handleEvent(peripheral: peripheral, characteristic: characteristic, type: .discover)
        }
    }
    
    public func handleDiscovered(services: [CBService]) {
        self.services = services
        
        services.forEach { service in
            self.handleDiscovered(service:service)
        }
    }
    
    public func handleDiscovered(service: CBService) {
        self.peripheral.discoverCharacteristics(nil, for: service)
    }
}

// MARK: Authentication
public extension CK300Device {
    public func getAuthenticationState() -> Observable<CKAuthenticationState> {
        // --> Get login service
        // --> Get characteristics
        // --> Go hardcore
    
        let foundService = self.services.filter { service in service.uuid.uuidString == "003065A4-1001-11E8-A8D5-435154454348" }
        
        if !foundService.isEmpty {
            print("Found auth")
        }
        
        
        return Observable.of(.unauthenticated)
    }
    
    public func login(withPassword password: String) -> Observable<CKAuthenticationState> {
         return Observable.of(.unauthenticated)
    }
    
//    public func login(withPassword password: String) {
//        print("== Performing login ==")
//
//        self.password = password
//        if let service = services["authentication"] {
//            self.peripheral.discoverServices([service.UUID])
//        }
//    }
}
