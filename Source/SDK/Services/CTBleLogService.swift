//
//  CTBleLogService.swift
//  ctble
//
//  Created by Gert-Jan Vercauteren on 18/01/2019.
//

import Foundation
import RxSwift

public class CTBleLogService: NSObject {

    public static let shared = CTBleLogService()

    public let logSubject = PublishSubject<String>()
    private var logItems: [CTLogItem] = []
    private var logLines: String = ""

    private override init() { // Use shared instead.
        super.init()
    }

    public func clearLog() {
        logItems = []
    }

    internal func addCodableLogEntry<T>(_ entry: T) where T: Codable {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(entry)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            let date = Date()
            let logItem = CTLogItem(date: date, type: "\(T.self)", data: jsonString)

            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"

            logLines += "[\(formatter.string(from: date))][\(T.self)] \(jsonString)\n"
            logItems.append(logItem)

            logSubject.onNext(logLines)
        } catch {
            print(error)
        }
    }
}
