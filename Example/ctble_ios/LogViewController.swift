//
//  LogViewController.swift
//  ctble_Example
//
//  Created by Gert-Jan Vercauteren on 18/01/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import ctble

class LogViewController: UIViewController {
    
    @IBOutlet weak var logTextView: UITextView!
    
    let disposeBag = DisposeBag()
    var scrollBottom = true
    @IBOutlet weak var scrollModeButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logTextView.scrollsToTop = false
        self.title = "Log"
    }
    @IBAction func toggleScrollMode(_ sender: Any) {
        self.scrollBottom = !self.scrollBottom
        
        if self.scrollBottom {
            scrollModeButton.title = "⏬"
        } else {
            scrollModeButton.title = "↕️"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CTBleLogService.shared.logSubject
            .throttle(1, scheduler: MainScheduler.instance)
            .subscribe(onNext: { logLines in
                
                self.logTextView.text = logLines
                
                if self.scrollBottom {
                    let bottom = NSMakeRange(self.logTextView.text.count - 1, 1)
                    self.logTextView.scrollRangeToVisible(bottom)
                }
        }).disposed(by: disposeBag)
    }
}
