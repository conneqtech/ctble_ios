//
//  CTLogItem.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 18/01/2019.
//

import Foundation

public struct CTLogItem: Codable {
    public var date:Date
    public var type: String
    public var data: String
}
