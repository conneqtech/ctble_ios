//
//  CTVariableInformationServiceDelegate.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 15/01/2019.
//

import Foundation

public protocol CTVariableInformationServiceDelegate: class {
    func didUpdateBikeInformation(_ bikeInformation: CTBikeInformation)
    func didUpdateBatteryInformation(_ batteryInformation: CTBatteryInformation)
    func didUpdateMotorInformation(_ motorInformation: CTMotorInformation)
}
