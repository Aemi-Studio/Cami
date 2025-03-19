//
//  DataContext+Birthdays.swift
//  Cami
//
//  Created by Guillaume Coquard on 26/01/25.
//

import EventKit
import Foundation

// MARK: - Birthdays

// MARK: - Computed Properties - Birthdays

extension DataContext {
    var birthdayCalendar: EKCalendar? {
        allCalendars.first { calendar in
            calendar.type == .birthday
        }
    }

    var birthdays: [EKEvent] {
        birthdays(from: .now, during: 90)
    }
}

extension DataContext {
    func birthdays(from date: Date, during days: Int = 365) -> [EKEvent] {
        guard let birthdayCalendar else { return [] }

        eventStore.refreshSourcesIfNecessary()

        let calendar = Calendar.autoupdatingCurrent

        var todayComponent = DateComponents()
        todayComponent.day = 0

        guard let today = calendar.date(byAdding: todayComponent, to: date, wrappingComponents: false)
        else { return [EKEvent]() }

        // Create the end date components.
        var limit = DateComponents()
        limit.day = days

        guard let endDate = calendar.date(byAdding: limit, to: date, wrappingComponents: false)
        else { return [EKEvent]() }

        // Create the predicate from the event store's instance method.
        let predicate = eventStore.predicateForEvents(withStart: today, end: endDate, calendars: [birthdayCalendar])

        // Fetch all events that match the predicate.
        return eventStore.events(matching: predicate).sorted(.orderedAscending)
    }
}
