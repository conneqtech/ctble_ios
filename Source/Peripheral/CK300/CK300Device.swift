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

public enum CK300Data {
    case authentication
    case bikeStatic
    case variable
}

public class CK300Device: CTBlePeripheral {
    public var peripheral: CBPeripheral!

    public var dataServices: [CK300Data: CTBleServiceProtocol] = [
        .authentication         :   CKAuthenticationService(),
        .bikeStatic                 :   CKStaticInformationService(),
        .variable               :   CKVariableInformationService()
    ]
    
    private let totalServices = 5
    private var status: CK300DeviceStatus = .notSetup
    internal var state: [CK300Field: Any] = [:]
    
    public var deviceStatus: PublishSubject = PublishSubject<CK300DeviceStatus> ()
    public var deviceState: PublishSubject = PublishSubject<[CK300Field: Any]> ()
    
    public var password = ""
    
    public required init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }
    
    internal func handleEvent(characteristic: CBCharacteristic, type: CTBleEventType) {
        self.dataServices.keys.forEach { key in
            self.dataServices[key]!.handleEvent(peripheral: peripheral, characteristic: characteristic, type: type)
        }
    }
}


// MARK: Data
public extension CK300Device {
    
    public func setupDevice() {
        self.updateDeviceStatus(newStatus: .settingUp)
        self.peripheral.discoverServices(nil)
    }
    
    public func getData(withServiceType type: CK300Data) {
        if self.status != .ready {
            print("🚫 Device is not ready")
            return
        }
        
        if let dataService = dataServices[type] {
            print("⚡️ Service `\(type)` is being fetched")
            dataService.setup(withDevice: self)
        } else {
            print("⚠️ Service `\(type)` is not implemented")
        }
    }
}

internal extension CK300Device {
    internal func updateDeviceStatus(newStatus status: CK300DeviceStatus) {
        self.status = status
        self.deviceStatus.onNext(self.status)
    }
}

// MARK: Handlers
public extension CK300Device {
    public func handleDiscovered(characteristics: [CBCharacteristic], forService service: CBService) {
        var finishedServices = 0
        if let services = peripheral.services {
            services.forEach { service in
                if let _ = service.characteristics {
                    finishedServices += 1
                }
            }
        }
        
        if finishedServices == totalServices {
            self.updateDeviceStatus(newStatus: .ready)
        }
    }
    
    public func handleDiscovered(services: [CBService]) {
        services.forEach { service in
            self.handleDiscovered(service:service)
        }
    }
    
    public func handleDiscovered(service: CBService) {
        self.peripheral.discoverCharacteristics(nil, for: service)
    }
}
