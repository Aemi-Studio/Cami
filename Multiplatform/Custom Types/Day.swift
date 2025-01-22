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
final class Day: Identifiable, Hashable {

    private struct SourceCalendars {
        var identifiers: [String]?
        var ekCalendars: Calendars?
    }

    static func == (lhs: Day, rhs: Day) -> Bool {
        lhs.date == rhs.date
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
        hasher.combine(date)
    }

    let identifier: UUID = UUID()
    let date: Date

    private var sourceCalendars: SourceCalendars?

    var calendars: Set<String>?
    var events: Events?
    var birthdays: Events?

    init(_ date: Date) {
        self.date = date
    }

    init(
        _ date: Date,
        from calendars: [String]
    ) {
        self.date = date
        self.sourceCalendars = SourceCalendars(identifiers: calendars)
    }

    init(
        _ date: Date,
        from calendars: Calendars
    ) {
        self.date = date
        self.sourceCalendars = SourceCalendars(ekCalendars: calendars)
    }

    @discardableResult
    func lazyInit() async -> Day {
        await self.lazyInitEvents()
        await self.lazyInitCalendars()
        await self.lazyBirthdays()
        return self
    }

    @discardableResult
    func lazyInitEvents() async -> Events {
        if self.events == nil {
            let calendars = self.sourceCalendars?.ekCalendars
                ?? self.sourceCalendars?.identifiers?.asEKCalendars()
                ?? CamiHelper.allCalendars
            self.events = EventHelper.events(from: calendars, during: 1, relativeTo: date )
        }
        return self.events!
    }

    @discardableResult
    func lazyInitEvents(from calendars: [String]) async -> Events {
        if self.events == nil {
            self.events = EventHelper.events(from: calendars.asEKCalendars(), during: 1, relativeTo: date )
        }
        return self.events!
    }

    @discardableResult
    func lazyInitEvents(from calendars: Calendars) async -> Events {
        if self.events == nil {
            self.events = EventHelper.events(from: calendars, during: 1, relativeTo: date )
        }
        return self.events!
    }

    @discardableResult
    func lazyInitCalendars() async -> Set<String> {
        if events == nil && self.calendars == nil {
            let unwrappedEvents: Events = events
                ?? self.events
                ?? EventHelper.events(
                    from: CamiHelper.allCalendars,
                    during: 1,
                    relativeTo: self.date
                )

            self.calendars = unwrappedEvents.reduce(into: Set<String>()) { result, event in
                result.insert( event.calendar.calendarIdentifier )
            }
        }
        return self.calendars!
    }

    @discardableResult
    func lazyBirthdays() async -> Events {
        if self.birthdays == nil {
            self.birthdays = EventHelper.birthdays(from: self.date, during: 1)
        }
        return self.birthdays!
    }

}
