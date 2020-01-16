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

public class CK300Device: CTDevice {
    var dataServices: [CK300Data: CTBleServiceProtocol] = [
//        .authentication         :   CKAuthenticationService(),
        .bikeStatic                 :   CKStaticInformationService(),
        .variable               :   CKVariableInformationService()
    ]
    
    private let totalServices = 5
    private var status: CK300DeviceStatus = .notSetup
    internal var state: [CK300Field: Any] = [:]
    
    public var deviceStatus: PublishSubject = PublishSubject<CK300DeviceStatus> ()
    public var deviceState: PublishSubject = PublishSubject<[CK300Field: Any]> ()
    
    private let authService = CKAuthenticationService()
    
    public var password = ""

    override public func handleEvent(characteristic: CBCharacteristic, type: CTBleEventType) {
        self.dataServices.keys.forEach { key in
            self.dataServices[key]!.handleEvent(peripheral: blePeripheral, characteristic: characteristic, type: type)
        }
        
        self.authService.handleEvent(peripheral: blePeripheral, characteristic:characteristic, type:type)
    }

    override public func handleDiscovered(characteristics: [CBCharacteristic], forService service: CBService) {
        var finishedServices = 0
        if let services = blePeripheral.services {
            services.forEach { service in
                if let _ = service.characteristics {
                    finishedServices += 1
                }
            }
        }

        if finishedServices == totalServices && status != .ready {
            self.updateDeviceStatus(newStatus: .ready)
        }
    }

    override public func handleDiscovered(services: [CBService]) {
        services.forEach { service in
            print(service.uuid.uuidString)
            self.handleDiscovered(service:service)
        }
    }

    func handleDiscovered(service: CBService) {
        self.blePeripheral.discoverCharacteristics(nil, for: service)
    }
}


// MARK: Data
public extension CK300Device {
    
    func setupDevice() {
        self.updateDeviceStatus(newStatus: .settingUp)
        self.blePeripheral.discoverServices(nil)
    }
    
    func getData(withServiceType type: CK300Data) {
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
    func updateDeviceStatus(newStatus status: CK300DeviceStatus) {
        self.status = status
        self.deviceStatus.onNext(self.status)
    }
}

public extension CK300Device {
    
    func startAuthentication(withPassword password: String) {
        print("Start authing")
        self.authService.startAuthentication(withPassword: password, andDevice: self)
    }
}

public extension CK300Device {
    
    private func getControlService() -> CBService? {
        let filteredService = self.blePeripheral.services?.filter { service in
            service.uuid.uuidString == "003065A4-10A0-11E8-A8D5-435154454348"
        }
        
        return filteredService?.first
    }
    
    private func getCharacteristic(fromService service: CBService, uuid: String) -> CBCharacteristic? {
        let filteredCharacteristic = service.characteristics?.filter { characteristic in
            characteristic.uuid.uuidString == uuid
        }
        
        return filteredCharacteristic?.first
    }
    
    func turnBikeOn() {
        send(value: 1, forCharacteristicUUID: "003065A4-10A1-11E8-A8D5-435154454348")
    }
    
    func turnBikeOff() {
        send(value: 0, forCharacteristicUUID: "003065A4-10A1-11E8-A8D5-435154454348")
    }
    
    func turnLightsOn() {
        send(value: 1, forCharacteristicUUID: "003065A4-10A2-11E8-A8D5-435154454348")
    }
    
    func turnLightsOff() {
        send(value: 0, forCharacteristicUUID: "003065A4-10A2-11E8-A8D5-435154454348")
    }
    
    func turnECULockOn() {
        send(value: 1, forCharacteristicUUID: "003065A4-10A3-11E8-A8D5-435154454348")
    }
    
    func turnECULockOff() {
        send(value: 0, forCharacteristicUUID: "003065A4-10A3-11E8-A8D5-435154454348")
    }
    
    func turnERLLockOn() {
        send(value: 1, forCharacteristicUUID: "003065A4-10A4-11E8-A8D5-435154454348")
    }
    
    func turnERLLockOff() {
        send(value: 0, forCharacteristicUUID: "003065A4-10A4-11E8-A8D5-435154454348")
    }
    
    func setSupportMode(_ mode: Int) {
        send(value: mode, forCharacteristicUUID: "003065A4-10A5-11E8-A8D5-435154454348")
    }
    
    
    private func send(value: Int, forCharacteristicUUID uuid: String) {
        print("prepare send")
        if  let peripheral = self.blePeripheral,
            let controlService = getControlService(),
            let bikeChar = getCharacteristic(fromService: controlService, uuid: uuid) {
            print("SENDING")
            var command:Int8 = Int8(value)
            let data = Data(bytes: &command, count: MemoryLayout<Int8>.size)
            peripheral.writeValue(data, for: bikeChar, type: .withResponse)
        }
    }
}
