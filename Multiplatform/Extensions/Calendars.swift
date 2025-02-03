//
//  Calendars.swift
//  Cami
//
//  Created by Guillaume Coquard on 16/11/23.
//

import EventKit
import Foundation

extension Calendars {
    var asIdentifiers: [String] {
        map { calendar in
            calendar.calendarIdentifier
        }
    }
}

extension [String] {
    func asEKCalendars() -> Calendars {
        let optionalCalendarList = map { calendar in
            DataContext.shared.get(calendar: calendar)
        }
        return optionalCalendarList.filter { calendar in
            calendar != nil
        } as? Calendars ?? []
    }
}
