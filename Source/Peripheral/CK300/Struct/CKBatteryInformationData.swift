//
//  CKBatteryInformationData.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 17/01/2019.
//

import Foundation

public struct CKBatteryInformationData {
    public var fccMah: Int
    public var fccPercentage: Int
    public var chargingCycles: Int
    public var packVoltage: Int
    public var temperature: Int
    public var errors: String
    public var state: Int
    public var backupBatteryVoltage: Int
}
