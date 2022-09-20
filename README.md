# ctble_ios

To start searching:
            func startSearching() {
              // This will trigger the bluetooth to go on and update the state in the delegate.
              // When the state updates to poweredOn, we start the scanning.

              CTBleManager.shared.delegate = self
              CTBleManager.shared.deviceFilterName = deviceFilterName

              // Setup the timers to check the results.
              setupTimers()

              dPrint("Setting up")
          }
          
to connect:
      CTBleManager.shared.connectBleDevice(device)
    


Example: 
        
        extension BikeCreateCoordinator: BluetoothServiceDelegate {
    func searchDidEnd(withDevices devices: [CTDevice]) {
        if devices.count == 1 {
            // Connect to the found bike
            if let bleName = devices.first?.blePeripheral.name {
                bluetoothName = bleName
            }
            bluetoothService?.connect(toDevice: devices.first!)
            return
        }
        
        // Reset in case we re-run
        bluetoothName = ""
        
        if devices.isEmpty {
            foundNoBike()
        }
        
        if devices.count > 1 {
            foundTooManyBikes()
        }
        
        bluetoothService?.delegate = nil
    }
    
    func didConnect(withDevice: CTDevice, batteryPercentage: Int, supportMode: Int) {
        foundOneBike(batteryPercentage: batteryPercentage, supportMode: supportMode)
    }
    
    // When connecting takes too long, we cut the connection and show the 'error' screen.
    // We will display no bike was found.
    func didTimeoutConnection() {
        foundNoBike()
        bluetoothService?.delegate = nil
    }
}
