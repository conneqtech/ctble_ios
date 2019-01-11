//
//  DeviceDetailViewController.swift
//  ctble_Example
//
//  Created by Gert-Jan Vercauteren on 11/01/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import ctble

class DeviceDetailViewController: UIViewController {
    override func viewDidLoad() {
        if let connectedDevice = CTBleManager.shared.connectedDevice {
            super.viewDidLoad()
            title = connectedDevice.peripheral.name!
        }
    }
    
}
