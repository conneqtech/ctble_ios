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

    func updateBikeInformation(_ bikeInformation: CKBikeInformationData) {
        self.delegate?.didUpdateBikeInformation(bikeInformation)
    }

    func updateBatteryInformation(_ batteryInformation: CKBatteryInformationData) {
        self.delegate?.didUpdateBatteryInformation(batteryInformation)
    }

    func updateMotorInformation(_ motorInformation: CKMotorInformationData) {
        self.delegate?.didUpdateMotorInformation(motorInformation)
    }
}
