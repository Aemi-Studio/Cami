//
//  Deeplink.swift
//  Cami
//
//  Created by Guillaume Coquard on 23/01/25.
//

import EventKit
import Foundation

extension DataContext {
    func destination(for event: EKEvent, inPlace: Bool = false) -> URL {
        if inPlace {
            guard let identifier = event.eventIdentifier else { return .init(string: "")! }
            return URL(string: "camical:event?id=\(identifier)")!
        } else {
            return URL(string: "calshow:\(event.startDate.timeIntervalSinceReferenceDate)")!
        }
    }

    func destination(for date: Date, inPlace: Bool = false) -> URL {
        if inPlace {
            URL(string: "camical:day?time=\(date.timeIntervalSinceReferenceDate)")!
        } else {
            URL(string: "calshow:\(date.timeIntervalSinceReferenceDate)")!
        }
    }

    //    public static func destination(for date: CNContact) -> URL {
    //        if UserDefaults.standard.bool(forKey: SettingsKeys.openInCami) {
    //            URL(string: "camical:contact?time=\(date.timeIntervalSinceReferenceDate)")!
    //        } else {
    //            URL(string: "calshow:\(date.timeIntervalSinceReferenceDate)")!
    //        }
    //    }
}
