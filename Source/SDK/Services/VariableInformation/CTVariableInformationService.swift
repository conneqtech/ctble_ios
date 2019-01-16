//
//  CTLocationService.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 15/01/2019.
//

import Foundation

public class CTVariableInformationService: NSObject {

    public static let shared = CTVariableInformationService()
    public var delegate: CTVariableInformationServiceDelegate?

    private override init() { // Use shared instead.
        super.init()
    }

    func updateBikeInformation(_ bikeInformation: CTBikeInformation) {
        self.delegate?.didUpdateBikeInformation(bikeInformation)
    }

    func updateBatteryInformation(_ batteryInformation: CTBatteryInformation) {
        self.delegate?.didUpdateBatteryInformation(batteryInformation)
    }

    func updateMotorInformation(_ motorInformation: CTMotorInformation) {
        self.delegate?.didUpdateMotorInformation(motorInformation)
    }
}
