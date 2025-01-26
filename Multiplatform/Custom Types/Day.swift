//
//  Day.swift
//  Cami
//
//  Created by Guillaume Coquard on 21/11/23.
//

import Foundation
import SwiftUI
import EventKit

@Observable
final class Day: Identifiable, @unchecked Sendable {

    typealias ID = UUID

    private struct SourceCalendars: Equatable, Hashable {
        var identifiers: [String]?
        var ekCalendars: Calendars?
    }

    private var sourceCalendars: SourceCalendars?

    let id: ID = ID()
    let date: Date

    var calendars: Set<String>?
    var events: CItems?
    var birthdays: CItems?
    var reminders: CItems?

    init(_ date: Date) {
        self.date = date
    }

    init(_ date: Date, from calendars: [String]) {
        self.date = date
        self.sourceCalendars = SourceCalendars(identifiers: calendars)
    }

    init(_ date: Date, from calendars: Calendars) {
        self.date = date
        self.sourceCalendars = SourceCalendars(ekCalendars: calendars)
    }

    @discardableResult
    func lazyInit() -> Day {
        self.lazyInitEvents()
        self.lazyInitCalendars()
        self.lazyBirthdays()
        self.lazyReminders()
        return self
    }

    @discardableResult
    func lazyInitEvents() -> CItems {
        if let events { return events }

        let calendars = self.sourceCalendars?.ekCalendars
            ?? self.sourceCalendars?.identifiers?.asEKCalendars()
            ?? DataContext.shared.allCalendars

        events = DataContext.shared.events(from: calendars, during: 1, relativeTo: date)
        return events ?? []
    }

    @discardableResult
    func lazyInitEvents(from calendars: [String]) -> CItems {
        if let events { return events }

        events = DataContext.shared.events(from: calendars.asEKCalendars(), during: 1, relativeTo: date)
        return events ?? []
    }

    @discardableResult
    func lazyInitEvents(from calendars: Calendars) -> CItems {
        if let events { return events }

        events = DataContext.shared.events(from: calendars, during: 1, relativeTo: date )
        return events ?? []
    }

    @discardableResult
    func lazyInitCalendars() -> Set<String> {
        guard let calendars else {
            let events = events ?? DataContext.shared.events(during: 1, relativeTo: date)

            calendars = events.reduce(into: Set<String>()) { $0.insert($1.calendar.calendarIdentifier) }
            return calendars ?? []
        }
        return calendars
    }

    @discardableResult
    func lazyBirthdays() -> CItems {
        if let birthdays { return birthdays }

        birthdays = DataContext.shared.birthdays(from: date, during: 1)
        return self.birthdays ?? []
    }

    @discardableResult
    func lazyReminders() -> CItems {
        if let reminders { return reminders }

        reminders = DataContext.shared.reminders(where: Filters.any(of: [Filters.dueToday, Filters.open]).filter)
        return reminders ?? []
    }

}

extension Day: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
    }

    static func == (lhs: Day, rhs: Day) -> Bool {
        lhs.date == rhs.date
    }
}
