//
//  CTLocationService.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 15/01/2019.
//

import Foundation
import RxSwift

public class CTVariableInformationService: NSObject {

    public static let shared = CTVariableInformationService()

    public let bikeInformationSubject = PublishSubject<CKBikeInformationData>()
    public let batteryInformationSubject = PublishSubject<CKBatteryInformationData>()
    public let motorInformationSubject = PublishSubject<CKMotorInformationData>()

    private override init() { // Use shared instead.
        super.init()
    }

    func updateBikeInformation(_ bikeInformation: CKBikeInformationData) {
        CTBleLogService.shared.addCodableLogEntry(bikeInformation)
        bikeInformationSubject.onNext(bikeInformation)
    }

    func updateBatteryInformation(_ batteryInformation: CKBatteryInformationData) {
        CTBleLogService.shared.addCodableLogEntry(batteryInformation)
        batteryInformationSubject.onNext(batteryInformation)
    }

    func updateMotorInformation(_ motorInformation: CKMotorInformationData) {
        CTBleLogService.shared.addCodableLogEntry(motorInformation)
        motorInformationSubject.onNext(motorInformation)
    }
}
