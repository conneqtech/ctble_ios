//
//  CTStaticInformationService.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 25/01/2019.
//

import Foundation
import RxSwift

public class CTStaticInformationService: NSObject {
    
    public var data = CKStaticInformationData()
    public let staticInformationSubject = PublishSubject<CKStaticInformationData>()
    
    public static let shared = CTStaticInformationService()
    
    private override init() { // Use shared instead.
        super.init()
    }
    
    public func updateStaticInformation() {
        CTBleLogService.shared.addCodableLogEntry(data)
        staticInformationSubject.onNext(data)
    }
}
