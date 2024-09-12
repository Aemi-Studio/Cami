//
//  CamiHelper+Extensions.swift
//  Cami
//
//  Created by Guillaume Coquard on 11/09/24.
//

import Foundation
import EventKit

extension CamiHelper {
    public static func destination(for event: EKEvent, inPlace: Bool = false) -> URL {
        if inPlace {
            guard let identifier = event.eventIdentifier else { return .init(string: "")! }
            return URL(string: "camical:event?id=\(identifier)")!
        } else {
            return URL(string: "calshow:\(event.startDate.timeIntervalSinceReferenceDate)")!
        }
    }

    public static func destination(for date: Date, inPlace: Bool = false) -> URL {
        if inPlace {
            URL(string: "camical:day?time=\(date.timeIntervalSinceReferenceDate)")!
        } else {
            URL(string: "calshow:\(date.timeIntervalSinceReferenceDate)")!
        }
    }
}
