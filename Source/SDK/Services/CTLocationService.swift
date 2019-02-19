//
//  CTLocationService.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 15/01/2019.
//

import Foundation
import RxSwift

public class CTLocationService: NSObject {

    public static let shared = CTLocationService()
    public let locationSubject = PublishSubject<CKLocationData>()

    private override init() { // Use shared instead.
        super.init()
    }

    func updateLocation(_ locationData: CKLocationData) {
        locationSubject.onNext(locationData)
    }
}
