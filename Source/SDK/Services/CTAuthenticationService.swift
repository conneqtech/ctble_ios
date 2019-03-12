//
//  CTAuthenticationService.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 11/03/2019.
//

import Foundation
import RxSwift

public class CTAuthenticationService: NSObject {
    
    public static let shared = CTAuthenticationService()
    
    public let authenticationStatusSubject = PublishSubject<Int>()
    
    private override init() { // Use shared instead.
        super.init()
    }
    
    func updateAuthenticationStatus(_ authStatus: Int) {
        authenticationStatusSubject.onNext(authStatus)
    }
    
}
