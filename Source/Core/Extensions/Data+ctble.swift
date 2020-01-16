//
//  Data+ctble.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 19/03/2019.
//

import Foundation

internal extension Data {
    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.load(as: T.self) }
    }
}
