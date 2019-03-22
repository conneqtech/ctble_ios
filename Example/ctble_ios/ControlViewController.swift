//
//  ControlViewController.swift
//  ctble_Example
//
//  Created by Gert-Jan Vercauteren on 19/03/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import ctble
import RxSwift

class ControlViewController: UIViewController {
    
    var device: CK300Device?
    var disposeBag = DisposeBag()
    var passwordTextField: UITextField?
    
    @IBOutlet var buttons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        buttons.forEach { $0.isEnabled = false }
        CTAuthenticationService.shared.authenticationStatusSubject.subscribe(onNext: { state in
            if state == 0 {
                self.enableButtons()
            }
            
            if state == -1 {
                self.openAlertView()
            }
            
        }).disposed(by: disposeBag)
        
        if let device = CTBleManager.shared.connectedDevice {
            self.device = device
            self.device?.startAuthentication(
                withPassword: UserDefaults.standard.string(forKey: "blePassword") ?? "")
        }
    }
    
    @IBAction func turnBikeOn(_ sender: Any) {
        if let device = self.device {
            device.turnBikeOn()
        }
    }
    
    @IBAction func turnBikeOff(_ sender: Any) {
        if let device = self.device {
            device.turnBikeOff()
        }
    }
    
    @IBAction func turnLightsOn(_ sender: Any) {
        if let device = self.device {
            device.turnBikeOn()
        }
    }
    
    @IBAction func turnLightsOff(_ sender: Any) {
        if let device = self.device {
            device.turnLightsOff()
        }
    }
    
    @IBAction func turnECULockOn(_ sender: Any) {
        if let device = self.device {
            device.turnECULockOn()
        }
    }
    
    @IBAction func turnECULockOff(_ sender: Any) {
        if let device = self.device {
            device.turnECULockOff()
        }
    }
    
    @IBAction func turnERLLockOn(_ sender: Any) {
        if let device = self.device {
            device.turnERLLockOn()
        }
    }
    
    @IBAction func turnERLLockOff(_ sender: Any) {
        if let device = self.device {
            device.turnERLLockOff()
        }
    }
    
    @IBAction func turnDigitalioOn(_ sender: Any) {
    }
    
    @IBAction func turnDigitalioOff(_ sender: Any) {
    }
    
    @IBAction func setSupportMode(_ sender: Any) {
        let alert = UIAlertController(
            title: "Support mode",
            message: "Select a support mode to send", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "0", style: .default, handler: { _ in
            self.setSupportMode(0)
        }))
        alert.addAction(UIAlertAction(title: "1", style: .default, handler: { _ in
            self.setSupportMode(1)
        }))
            
        alert.addAction(UIAlertAction(title: "2", style: .default, handler: { _ in
            self.setSupportMode(2)
        }))
        alert.addAction(UIAlertAction(title: "3", style: .default, handler: { _ in
            self.setSupportMode(3)
        }))
        alert.addAction(UIAlertAction(title: "4", style: .default, handler: { _ in
            self.setSupportMode(4)
        }))
        alert.addAction(UIAlertAction(title: "5", style: .default, handler: { _ in
            self.setSupportMode(5)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    private func setSupportMode(_ mode: Int) {
        if let device = self.device {
            device.setSupportMode(mode)
        }
    }
    
    
    func enableButtons() {
        buttons.forEach { $0.isEnabled = true }
    }
}

extension ControlViewController {
    func configurationTextField(textField: UITextField!) {
        if (passwordTextField) != nil {
            self.passwordTextField = passwordTextField!        //Save reference to the UITextField
            self.passwordTextField?.placeholder = "Password";
        }
        
        self.passwordTextField = textField
        self.passwordTextField?.placeholder = "Password"
    }
    
    func openAlertView() {
        let alert = UIAlertController(title: "Password", message: "Enter password for device", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        alert.addAction(UIAlertAction(title: "Unlock", style: .default, handler:{ (UIAlertAction) in
            if let password = self.passwordTextField?.text {
                UserDefaults.standard.set(password, forKey: "blePassword")
                self.device?.startAuthentication(
                    withPassword: password)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
