//
//  CKStaticInformationData.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 25/01/2019.
//

import Foundation

public struct CKStaticInformationData: Codable {
    public var bikeType: String
    public var bikeSerialNumber: String
    public var batterySerialNumber: String
    public var bikeSoftwareVersion: String
    public var controllerSoftwareVersion: String
    public var displaySoftwareVersion: String
    public var bikeDesignCapacity: Int
    public var wheelDiameter: Int
    public var bleVersion: String
    public var airVersion: String
    
    public init () {
        self.bikeType = ""
        self.bikeSerialNumber = ""
        self.batterySerialNumber = ""
        self.bikeSoftwareVersion = ""
        self.controllerSoftwareVersion = ""
        self.displaySoftwareVersion = ""
        self.bikeDesignCapacity = 0
        self.wheelDiameter = 0
        self.bleVersion = ""
        self.airVersion = ""
    }
}
