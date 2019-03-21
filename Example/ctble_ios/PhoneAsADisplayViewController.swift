//
//  PhoneAsADisplayViewController.swift
//  ctble_Example
//
//  Created by Gert-Jan Vercauteren on 15/01/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import ctble

class PhoneAsADisplayViewController: UIViewController {
    
    @IBOutlet weak var speedLabel: UILabel!
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var supportOne: UIView!
    @IBOutlet weak var supportTwo: UIView!
    @IBOutlet weak var supportThree: UIView!
    @IBOutlet weak var supportFour: UIView!
    @IBOutlet weak var supportFive: UIView!
    @IBOutlet weak var batteryPercentageLabel: UILabel!
    @IBOutlet weak var batteryPercentageBar: UIProgressView!
    @IBOutlet weak var rangeLabel: UILabel!
    @IBOutlet weak var odoLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.supportOne.layer.cornerRadius = 10
        self.supportTwo.layer.cornerRadius = 10
        self.supportThree.layer.cornerRadius = 10
        self.supportFour.layer.cornerRadius = 10
        self.supportFive.layer.cornerRadius = 10
        
        self.batteryPercentageBar.layer.cornerRadius = 10
        self.batteryPercentageBar.progressTintColor = UIColor(red:0.00, green:0.78, blue:0.33, alpha:1.0)
        
    CTBleManager.shared.connectedDevice?.deviceState.subscribe(onNext: { state in
            let speed = state[.bikeSpeed] ?? 0
            self.speedLabel.text = "\(speed) km/h"
        
        if let batteryPercent = state[.bikeBatterySOCPercentage] as? Int {
            self.batteryPercentageLabel?.text = "\(batteryPercent)%"
            self.batteryPercentageBar.progress = Float(batteryPercent) / 100
        }
        
        if let odometer = state[.bikeOdometer] as? Int {
            self.odoLabel?.text = "\(Float(odometer) / 1000) km odo"
        }
        
        if let range = state[.bikeRange] as? Int {
            self.rangeLabel?.text = "\(range) km range"
        }
        
        if let supportMode = state[.bikeSupportMode] as? Int {
            //Reset
            let emptyColor = UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)
            self.supportOne.backgroundColor = emptyColor
            self.supportTwo.backgroundColor = emptyColor
            self.supportThree.backgroundColor = emptyColor
            self.supportFour.backgroundColor = emptyColor
            self.supportFive.backgroundColor = emptyColor
            
            
            if supportMode >= 1 {
                self.supportOne.backgroundColor = UIColor(red:1.00, green:0.87, blue:0.01, alpha:1.0)
            }
            
            if supportMode >= 2 {
                self.supportTwo.backgroundColor = UIColor(red:1.00, green:0.70, blue:0.00, alpha:1.0)
            }
            
            if supportMode >= 3 {
                self.supportThree.backgroundColor = UIColor(red:1.00, green:0.56, blue:0.00, alpha:1.0)
            }
            
            if supportMode >= 4 {
                self.supportFour.backgroundColor = UIColor(red:1.00, green:0.44, blue:0.00, alpha:1.0)
            }
            
            if supportMode >= 5 {
                self.supportFive.backgroundColor = UIColor(red:0.90, green:0.32, blue:0.00, alpha:1.0)
            }
        }
        }).disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "📱 as a display"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        disposeBag = DisposeBag()
        super.viewDidDisappear(animated)
    }
    
    
}
