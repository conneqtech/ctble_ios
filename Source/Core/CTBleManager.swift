//
//  CTBleManager.swift
//  ConnectedLock
//
//  Created by Gert-Jan Vercauteren on 29/05/2018.
//  Copyright © 2018 Conneqtech. All rights reserved.
//

import Foundation
import CoreBluetooth

// MARK: - CTBLeManager base
public class CTBleManager: NSObject {
    public static let shared = CTBleManager()
    public var delegate = MulticastDelegate<CTBleManagerDelegate>()

    let timerPauseInterval:TimeInterval = 10.0
    let timerScanInterval:TimeInterval = 2.0

    var centralManager: CBCentralManager!
    var keepScanning = false

    public var connectedDevice: CK300Device?

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

    public func connectBleDevice(_ device: CK300Device) {
        print("== Attempting to connect to device ==")
        self.connectedDevice = device
        self.connectedDevice?.peripheral.delegate = self

        centralManager?.connect(self.connectedDevice!.peripheral, options: nil)
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
                delegate |> { delegate in
                    delegate.didDiscover(device)
                }
            }
        }
    }
}

// MARK: - CBPeripheral delegate
extension CTBleManager: CBPeripheralDelegate {
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let device = self.connectedDevice {
            delegate |> { delegate in
                delegate.didConnect(device)
            }
        }
    }

    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        let device = CK300Device(peripheral: peripheral)
        delegate |> { delegate in
            delegate.didFailToConnect(device)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        self.connectedDevice?.peripheral = peripheral

        peripheral.services?.forEach {
            self.connectedDevice?.handleDiscoveredService($0)
        }
        
        if let foundService = peripheral.services?.first {
             self.connectedDevice?.discoverCharacteristics(for: foundService)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral,
                           didDiscoverCharacteristicsFor service: CBService,
                           error: Error?) {
        self.connectedDevice?.peripheral = peripheral

        service.characteristics?.forEach { characteristic in
            self.connectedDevice?.handleDiscoveredCharacteristic(characteristic)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("== Did write characteristic")
        self.connectedDevice?.handleCharacteristicWrite(characteristic)
    }

    public func peripheral(_ peripheral: CBPeripheral,
                           didUpdateNotificationStateFor characteristic: CBCharacteristic,
                           error: Error?) {
        print("notif state")
    }

    public func peripheral(_ peripheral: CBPeripheral,
                           didUpdateValueFor characteristic: CBCharacteristic,
                           error: Error?) {
        self.connectedDevice?.peripheral = peripheral
        self.connectedDevice?.handleCharacteristicUpdate(characteristic)
    }
}
