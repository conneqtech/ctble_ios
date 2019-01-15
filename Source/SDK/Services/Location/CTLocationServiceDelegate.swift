//
//  CTLocationServiceDelegate.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 15/01/2019.
//

import Foundation

public protocol CTLocationServiceDelegate: class {
    func didUpdateLocation(deviceName: String, lat: Double, lon: Double, altitude: Int)
}
