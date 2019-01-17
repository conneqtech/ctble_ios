//
//  CKMotorInformationData.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 17/01/2019.
//

import Foundation

public struct CKMotorInformationData {
    public var actualTorque: Int
    public var wheelSpeed: Int
    public var motorPower: Int
    public var motorError: String
    public var pedalCadence: Int
    public var pedalPower: Int
    public var receivedSignalStrength: Int
}
