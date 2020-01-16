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
    public var deviceFilterName = "CK300"
    public let bluetoothManagerStatusSubject = PublishSubject<CBManagerState>()

    var devices:[CTBleManagerDevice] = []



    let timerPauseInterval:TimeInterval = 10.0
    let timerScanInterval:TimeInterval = 2.0

    public var centralManager: CBCentralManager!
    var keepScanning = false

    let services:[CBUUID] = [
//        CBUUID(string: "003065A4-1001-11E8-A8D5-435154454348"),
//        CBUUID(string: "003065A4-1020-11E8-A8D5-435154454348"),
//        CBUUID(string: "003065A4-1050-11E8-A8D5-435154454348")//,
        //                CBUUID(string: "003065A4-10A0-11E8-A8D5-435154454348"),
        //                CBUUID(string: "003065A4-10B0-11E8-A8D5-435154454348")
    ]

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




            centralManager.scanForPeripherals(withServices: services, options: nil)
        }
    }

    public func disconnectAllDevices() {
        for device in devices {
            centralManager.cancelPeripheralConnection(device.device.blePeripheral)
        }
    }

    public func startScanForPeripherals() {
        centralManager?.scanForPeripherals(withServices: services, options: nil)
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

    public func rangeForPeripheral(_ peripheral: CBPeripheral) {

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
        default:
            break
        }
        
        bluetoothManagerStatusSubject.onNext(central.state)

        print(message)
    }

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            print("Trying to match: \(peripheralName)")
            if peripheralName.lowercased().contains(deviceFilterName.lowercased()) || deviceFilterName == "" {
                print("\t✅ \(peripheralName) matched with '\(deviceFilterName)'")
                let device = CK300Device(peripheral: peripheral)
                devices = devices.filter {$0.device.blePeripheral.name != peripheral.name}
                devices.append(CTBleManagerDevice(device: device, deviceType: .ck300, connectionState: .disconnected))

                delegate?.didDiscover(device)
            } else{
                print("\t❌ \(peripheralName) not matched with: '\(deviceFilterName)'")
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
