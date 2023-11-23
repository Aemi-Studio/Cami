//
//  Day.swift
//  Cami
//
//  Created by Guillaume Coquard on 21/11/23.
//

import Foundation
import SwiftUI
import EventKit

@Observable class Day: Identifiable, Hashable {

    static func == (lhs: Day, rhs: Day) -> Bool {
        lhs.date == rhs.date
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
        hasher.combine(date)
    }

    let identifier:     UUID = UUID()
    let date:           Date


    typealias S = String
    var calendars: Set<String> {
        self.events.reduce(into: Set<S>()) { r, e in
            r.insert( e.calendar.calendarIdentifier )
        }
    }

    var events: Events

    var birthday: Events

    init(_ date: Date) {
        self.date = date
        self.events = CalendarHelper.events(from: CamiHelper.allCalendars, during: 1, relativeTo: date)
        self.birthday = CalendarHelper.birthdays(from: date, during: 1)
    }

    init(
        _ date: Date,
        from calendars: Calendars = CamiHelper.allCalendars
    ) {
        self.date = date
        self.events = CalendarHelper.events(from: calendars, during: 1, relativeTo: date)
        self.birthday = CalendarHelper.birthdays(from: date, during: 1)
    }

    init(
        _ date: Date,
        from calendars: [String] = CamiHelper.allCalendars.asIdentifiers
    ) {
        self.date = date
        self.events = CalendarHelper.events(from: calendars, during: 1, relativeTo: date)
        self.birthday = CalendarHelper.birthdays(from: date, during: 1)    }

}
