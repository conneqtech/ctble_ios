//
//  CTVariableInformationServiceDelegate.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 15/01/2019.
//

import Foundation

public protocol CTVariableInformationServiceDelegate: class {
    func didUpdateBikeInformation(_ bikeInformation: CKBikeInformationData)
    func didUpdateBatteryInformation(_ batteryInformation: CKBatteryInformationData)
    func didUpdateMotorInformation(_ motorInformation: CKMotorInformationData)
}
