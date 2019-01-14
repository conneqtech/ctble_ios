//
//  DeviceListTableViewController.swift
//  ctble_Example
//
//  Created by Gert-Jan Vercauteren on 11/01/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import ctble
import CoreBluetooth

class DeviceListTableViewController: UITableViewController {
    
    var devices: [CK300Device] = []
    
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        CTBleManager.shared.startScanForPeripherals()
        CTBleManager.shared.delegate += self
        
        let refreshBarButton: UIBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.rightBarButtonItem = refreshBarButton
    }
}

extension DeviceListTableViewController: CTBleManagerDelegate {
    func didDiscover(_ device: CK300Device) {
        devices.append(device)
        tableView.reloadData()
    }
    
    func didConnect(_ device: CK300Device) {
        print("Connected")
        activityIndicator.stopAnimating()
        
        
        let alertController = UIAlertController(title: "Enter password", message: "Please enter the password for \(device.peripheral.name!)", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Unlock", style: .default, handler: { alert -> Void in
            let passwordTextField = alertController.textFields![0] as UITextField
            
            print(passwordTextField.text)
            
            if let password = passwordTextField.text {
                CTBleManager.shared.connectedDevice?.login(withPassword: password)
                CTBleManager.shared.connectedDevice?.getStaticInformation()
            }
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "deviceDetailViewController")
            self.navigationController?.pushViewController(vc, animated: true)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Password"
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func didFailToConnect(_ device: CK300Device) {
        print("Connection failed")
    }
}

//MARK: - UITableViewDataSource
extension DeviceListTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devices.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "deviceCell", for: indexPath)
        let device = self.devices[indexPath.row]
        
        cell.textLabel?.text = "CK300"
        
        if let identifier = device.peripheral.name?.split(separator: "-").last {
            cell.detailTextLabel?.text = "\(identifier)"
        }
        
        return cell
    }
    
}

//MARK: - UITableViewDelegate
extension DeviceListTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let device = devices[indexPath.row]
        CTBleManager.shared.connectBleDevice(device)
        activityIndicator.startAnimating()
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}

