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

    func updateLocation(withDeviceName deviceName: String, lat: Double, lon: Double, altitude: Int) {
        let data = CKLocationData(latitude: lat, longitude: lon, altitude: altitude)
        locationSubject.onNext(data)
    }
}
