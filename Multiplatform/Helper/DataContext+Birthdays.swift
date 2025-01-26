//
//  DataContext+Birthdays.swift
//  Cami
//
//  Created by Guillaume Coquard on 26/01/25.
//

import Foundation
import EventKit

// MARK: - Birthdays

// MARK: - Computed Properties - Birthdays

extension DataContext {

    var birthdayCalendar: EKCalendar? {
        allCalendars.first { calendar in
            calendar.type == .birthday
        }
    }

    var birthdays: Events {
        birthdays(from: .now, during: 365)
    }

}

extension DataContext {

    public func birthdays(from date: Date, during days: Int = 365) -> Events {

        log.debug("Retrieving birthdays.")

        guard let birthdayCalendar else { return Events() }

        log.debug("Refresh storage.")

        eventStore.refreshSourcesIfNecessary()

        let calendar = Calendar.autoupdatingCurrent

        var todayComponent = DateComponents()
        todayComponent.day = 0

        guard let today = calendar.date(byAdding: todayComponent, to: date, wrappingComponents: false)
        else { return Events() }

        // Create the end date components.
        var limit = DateComponents()
        limit.day = days

        guard let endDate = calendar.date(byAdding: limit, to: date, wrappingComponents: false)
        else { return Events() }

        log.debug("Create the predicate.")

        // Create the predicate from the event store's instance method.
        let predicate = eventStore.predicateForEvents(withStart: today, end: endDate, calendars: [birthdayCalendar])

        log.debug("Fetching the events.")
        // Fetch all events that match the predicate.
        let events = eventStore.events(matching: predicate).sorted(.orderedAscending)

        log.debug("Returning the events. \(String(describing: events))")
        return events
    }

}
