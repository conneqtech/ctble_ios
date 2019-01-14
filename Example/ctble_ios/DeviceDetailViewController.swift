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

class DeviceDetailViewController: UITableViewController {
    
    var device: CK300Device!
    
    override func viewDidLoad() {
        if let connectedDevice = CTBleManager.shared.connectedDevice {
            super.viewDidLoad()
            title = connectedDevice.peripheral.name!
        }
    }
}

//MARK: - UITableViewDataSource
extension DeviceDetailViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Static information"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "staticInformationCell", for: indexPath)
        
        cell.textLabel?.text = "CK300"
        cell.detailTextLabel?.text = "CK300-1"
        
        return cell
    }
    
}

//MARK: - UITableViewDelegate
extension DeviceDetailViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

