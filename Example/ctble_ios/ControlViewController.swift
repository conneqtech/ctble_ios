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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CTAuthenticationService.shared.authenticationStatusSubject.subscribe(onNext: { state in
            if state == 0 {
                self.enableButtons()
            }
        }).disposed(by: disposeBag)
        
        if let device = CTBleManager.shared.connectedDevice {
            self.device = device
            self.device?.startAuthentication(withPassword: "|o&C>76CNsJ%`0h9k?&I")
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
    
    
    func enableButtons() {
        print("GO GO GO")
    }
}
