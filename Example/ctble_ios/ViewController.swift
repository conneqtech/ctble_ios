//
//  ViewController.swift
//  ctble_ios
//
//  Created by jookes on 01/10/2019.
//  Copyright (c) 2019 jookes. All rights reserved.
//

import UIKit
import ctble

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        CTBleManager.shared.startScanForPeripherals()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

