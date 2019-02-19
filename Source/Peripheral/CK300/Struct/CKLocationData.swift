//
//  CKLocationData.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 18/01/2019.
//

import Foundation

public struct CKLocationData: Codable {
    public var latitude: Double
    public var longitude: Double
    public var altitude: Int
    public var hdop: Int
    public var speed: Int
}
