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

    public var services: [CK300Service: CTBleServiceProtocol] = [
        .authentication         :   CKAuthenticationService(),
        .staticInfomation       :   CKStaticInformationService(),
        .locationInformation    :   CKLocationService(),
        .bikeInformation        :   CKBikeInformationService(),
        .batteryInformation     :   CKBatteryInformationService(),
        .motorInformation       :   CKMotorInformationService()
    ]
    
    public var password = ""

    public var UUIDList: [String: String] = [:]

    public var discoveredCharacteristics: [String: CBCharacteristic] = [:]

    public required init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }
    
    public func startReportingLocationData() {
        if let service = services[.locationInformation] {
            self.peripheral.discoverServices([service.UUID])
        }
    }
    
    internal func handleEvent(characteristic: CBCharacteristic, type: CTBleEventType) {
        self.services.keys.forEach { key in
            self.services[key]!.handleEvent(peripheral: peripheral, characteristic: characteristic, type: type)
        }
    }
}

// MARK: Data
public extension CK300Device {
    
    public func getData(withServiceType type: CK300Service) {
        if let service = services[type] {
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
        
    }
    
    public func handleDiscovered(service: CBService) {
        self.peripheral.discoverCharacteristics(nil, for: service)
    }
}

// MARK: Authentication
public extension CK300Device {
    public func getAuthenticationState() -> Observable<CKAuthenticationState> {
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
