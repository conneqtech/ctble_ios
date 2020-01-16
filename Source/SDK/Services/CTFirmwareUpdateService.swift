//
//  CTFirmwareUpdateService.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 23/10/2019.
//

import Foundation
import RxSwift

public class CTFirmwareUpdateService: NSObject {

    public static let shared = CTFirmwareUpdateService()

    public let firmwareUpdateStatusSubject = PublishSubject<String>()

    private override init() { // Use shared instead.
        super.init()
    }

    func updateFirmwareUpdateStatus(_ message: String) {
        firmwareUpdateStatusSubject.onNext(message)
    }
}
