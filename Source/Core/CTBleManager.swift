//
//  CTBleManager.swift
//  ConnectedLock
//
//  Created by Gert-Jan Vercauteren on 29/05/2018.
//  Copyright © 2018 Conneqtech. All rights reserved.
//

import Foundation
import CoreBluetooth

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

    var devices:[CTBleManagerDevice] = []

    let timerPauseInterval:TimeInterval = 10.0
    let timerScanInterval:TimeInterval = 2.0

    var centralManager: CBCentralManager!
    var keepScanning = false

    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    } // Use the shared variable

    @objc func pauseScan() {
        print("== Pausing scan ==")
        _ = Timer(timeInterval: timerPauseInterval,
                  target: self,
                  selector: #selector(resumeScan),
                  userInfo: nil,
                  repeats: false)
        centralManager.stopScan()
    }

    @objc func resumeScan() {
        if keepScanning {
            print("== Resuming scan ==")
            _ = Timer(timeInterval: timerScanInterval,
                      target: self,
                      selector: #selector(pauseScan),
                      userInfo: nil,
                      repeats: false)
            centralManager.scanForPeripherals(withServices: [], options: nil)
        }
    }

    public func startScanForPeripherals() {
        centralManager?.scanForPeripherals(withServices: [], options: nil)
    }

    public func stopScanForPeripherals() {
        centralManager?.stopScan()
    }

    public func disconnectPeripheral(_ peripheral: CBPeripheral) {
        centralManager?.cancelPeripheralConnection(peripheral)
    }

    public func connectBleDevice(_ device: CTDevice) {
        print("🔗 Trying to connect \(device.blePeripheral.name!)")

        centralManager?.connect(device.blePeripheral)

        /*
 , options: [
 CBConnectPeripheralOptionNotifyOnConnectionKey: true,
 CBConnectPeripheralOptionNotifyOnDisconnectionKey: true,
 CBConnectPeripheralOptionNotifyOnNotificationKey: true
 ]*/
    }
}

// MARK: - CBCentralManager delegate
extension CTBleManager: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var message = ""

        switch central.state {
        case .poweredOff:
            message = "Bluetooth on this device is currently powered off."
        case .unsupported:
            message = "This device does not support Bluetooth Low Energy."
        case .unauthorized:
            message = "This app is not authorized to use Bluetooth Low Energy."
        case .resetting:
            message = "The BLE Manager is resetting; a state update is pending."
        case .unknown:
            message = "The state of the BLE Manager is unknown."
        case .poweredOn:
            message = "Bluetooth LE is turned on and ready for communication."
            keepScanning = true

            _ = Timer(timeInterval: timerScanInterval, target: self, selector: #selector(pauseScan), userInfo: nil, repeats: false)
            centralManager.scanForPeripherals(withServices: [], options: nil)
        }

        print(message)
    }

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        if let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            if peripheralName.contains("CK300") {
                print("🚴‍♀️ \(peripheralName)")
                keepScanning = false

                let device = CK300Device(peripheral: peripheral)
                devices = devices.filter {$0.device.blePeripheral.name != peripheral.name}
                devices.append(CTBleManagerDevice(device: device, deviceType: .ck300, connectionState: .disconnected))

                delegate?.didDiscover(device)
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
