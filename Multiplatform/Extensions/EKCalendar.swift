//
//  EKCalendar.swift
//  Cami
//
//  Created by Guillaume Coquard on 16/11/23.
//

import EventKit
import Foundation

extension Sequence<EKCalendar> {
    var asIdentifiers: [String] {
        map(\.calendarIdentifier)
    }
}

extension Sequence<String> {
    func asEKCalendars() -> [EKCalendar] {
        compactMap { DataContext.shared.get(calendar: $0) }
    }
}
