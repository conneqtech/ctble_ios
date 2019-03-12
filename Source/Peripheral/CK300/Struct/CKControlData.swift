//
//  CKControlInformationData.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 11/03/2019.
//

import Foundation

public struct CKControlData: Codable {
    public var bikeStatus: Int
    public var lightStatus: Int
    public var ecuLockStatus: Int
    public var erLockStatus : Int
    public var supportMode: Int
    public var digitalIOStatus: Int

    public init () {
        self.bikeStatus = 0
        self.lightStatus = 0
        self.ecuLockStatus = 0
        self.erLockStatus = 0
        self.supportMode = 0
        self.digitalIOStatus = 0
    }
}
