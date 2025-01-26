//
//  Calendars.swift
//  Cami
//
//  Created by Guillaume Coquard on 16/11/23.
//

import Foundation
import EventKit

extension Calendars {
    var asIdentifiers: [String] {
        self.map { calendar in
            calendar.calendarIdentifier
        }
    }
}

extension Array<String> {
    func asEKCalendars() -> Calendars {
        let optionalCalendarList = self.map { calendar in
            DataContext.shared.get(calendar: calendar)
        }
        return optionalCalendarList.filter { calendar in
            calendar != nil
        } as? Calendars ?? []
    }
}
