//
//  CTBleManager.swift
//  ConnectedLock
//
//  Created by Gert-Jan Vercauteren on 29/05/2018.
//  Copyright © 2018 Conneqtech. All rights reserved.
//

import Foundation
import CoreBluetooth
import CoreLocation
import RxSwift

public class CTBleManagerDevice {
    public var device: CTDevice
    public var deviceType: CTDeviceType
    public var connectionState: CTBleDeviceConnectionState
    
    
    
    public init (device: CTDevice, deviceType: CTDeviceType, connectionState: CTBleDeviceConnectionState) {
        self.device = device
        self.deviceType = deviceType
        self.connectionState = connectionState
    }
}

// MARK: - CTBLeManager base
public class CTBleManager: NSObject {
    public static let shared = CTBleManager()
    public var delegate: CTBleManagerDelegate?
    public var deviceFilterNames = ["CK300", "HW40"]

    public var devices:[CTBleManagerDevice] = []
    
    let timerPauseInterval:TimeInterval = 10.0
    let timerScanInterval:TimeInterval = 2.0

    public var centralManager: CBCentralManager!
    var keepScanning = false

    let services:[CBUUID] = []

    public override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    @objc func pauseScan() {
        if centralManager.state != .poweredOn {
            return
        }
        print("== Pausing scan ==")
        _ = Timer(timeInterval: timerPauseInterval,
                  target: self,
                  selector: #selector(resumeScan),
                  userInfo: nil,
                  repeats: false)
        centralManager.stopScan()
    }

    @objc func resumeScan() {
        if centralManager.state != .poweredOn {
            return
        }
        if keepScanning {
            print("== Resuming scan ==")
            _ = Timer(timeInterval: timerScanInterval,
                      target: self,
                      selector: #selector(pauseScan),
                      userInfo: nil,
                      repeats: false)
            centralManager.scanForPeripherals(withServices: services, options: nil)
        }
    }

    public func disconnectAllDevices() {
        if centralManager.state != .poweredOn {
            return
        }
        for device in devices {
            centralManager.cancelPeripheralConnection(device.device.blePeripheral)
        }
    }

    public func startScanForPeripherals() {
        if centralManager.state != .poweredOn {
            return
        }
        centralManager?.scanForPeripherals(withServices: services, options: nil)
    }

    public func stopScanForPeripherals() {
        if centralManager.state != .poweredOn {
            return
        }
        centralManager?.stopScan()
    }

    public func disconnectPeripheral(_ peripheral: CBPeripheral) {
        if centralManager.state != .poweredOn {
            return
        }
        centralManager?.cancelPeripheralConnection(peripheral)
    }

    public func connectBleDevice(_ device: CTDevice) {
        if centralManager.state != .poweredOn {
            return
        }
        print("🔗 Trying to connect \(device.blePeripheral.name!)")

        centralManager?.connect(device.blePeripheral)
    }

    public func rangeForPeripheral(_ peripheral: CBPeripheral) {

    }
}

// MARK: - CBCentralManager delegate
extension CTBleManager: CBCentralManagerDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            keepScanning = true
            _ = Timer(timeInterval: timerScanInterval, target: self, selector: #selector(pauseScan), userInfo: nil, repeats: false)
            if centralManager.state == .poweredOn {
                centralManager.scanForPeripherals(withServices: [], options: nil)
            }
        }
        delegate?.didUpdateCentralState(central.state)
    }

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            for deviceFilterName in self.deviceFilterNames {
                if peripheralName.lowercased().starts(with: deviceFilterName.lowercased()) {
                    let device = CK300Device(peripheral: peripheral)
                    devices = devices.filter {$0.device.blePeripheral.name != peripheral.name}
                    devices.append(CTBleManagerDevice(device: device, deviceType: .ck300, connectionState: .disconnected))
                    delegate?.didDiscover(device)
                }
                
            }
        }
    }
}

// MARK: - Connection status manager
extension CTBleManager {
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let managedDevice = devices.filter({$0.device.blePeripheral.name == peripheral.name}).first {
            managedDevice.connectionState = .connected
            delegate?.didConnect(managedDevice.device)
        }
    }

    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let managedDevice = devices.filter({$0.device.blePeripheral.name == peripheral.name}).first {
            managedDevice.connectionState = .failedToConnect
            delegate?.didFailToConnect(managedDevice.device)
        }
    }

    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let managedDevice = devices.filter({$0.device.blePeripheral.name == peripheral.name}).first {
            managedDevice.connectionState = .disconnected
            delegate?.didDisconnect(managedDevice.device)
        }
    }
}
