//
//  CTBleCharacteristicMask.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 18/03/2019.
//

import Foundation

public struct CTBleCharacteristicMask {
    let range: Range<Int>
    let type: CTBleCharacteristicType
    let key: CK300Field
}
