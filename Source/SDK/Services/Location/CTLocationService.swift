//
//  CTLocationService.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 15/01/2019.
//

import Foundation

public class CTLocationService: NSObject {
    
    public static let shared = CTLocationService()
    public var delegate: CTLocationServiceDelegate?
    
    private override init() { // Use shared instead.
        super.init()
    }
    
    func updateLocation(withDeviceName deviceName: String, lat: Double, lon: Double, altitude: Int) {
        self.delegate?.didUpdateLocation(deviceName: deviceName, lat: lat, lon: lon, altitude: altitude)
    }
}
