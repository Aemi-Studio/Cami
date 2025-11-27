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
    @MainActor
    func asEKCalendars() async -> [EKCalendar] {
        var calendars: [EKCalendar] = []
        for id in self {
            if let calendar = await DataContext.shared.calendar(withIdentifier: id) {
                calendars.append(calendar)
            }
        }
        return calendars
    }
}
