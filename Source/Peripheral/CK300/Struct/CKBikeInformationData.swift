//
//  CKBikeInformationData.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 17/01/2019.
//

import Foundation

public struct CKBikeInformationData: Codable {
    public var bikeStatus: Int
    public var speed: Int
    public var range: Int
    public var odometer: Int
    public var bikeBatterySOC: Int
    public var bikeBatterySOCPercentage: Int
    public var supportMode: Int
    public var lightStatus: Int
}
