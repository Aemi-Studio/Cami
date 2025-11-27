//
//  EventService.swift
//  Cami
//
//  Created by Guillaume Coquard on 28/09/25.
//

import EventKit
import Foundation

/// Service for fetching and managing calendar events.
@MainActor
final class EventService {
    private let eventStoreService = EventStoreService.shared

    init() {}

    func event(for id: String) async -> EKEvent? {
        await eventStoreService.store.event(withIdentifier: id)
    }

    func events(
        from calendars: [EKCalendar],
        during days: Int,
        where filter: ((EKEvent) -> Bool) = { _ in true },
        relativeTo date: Date
    ) async -> [EKEvent] {
        let calendar = Calendar.autoupdatingCurrent

        var todayComponent = DateComponents()
        todayComponent.day = 0

        guard let today = calendar.date(byAdding: todayComponent, to: date, wrappingComponents: false)
        else {
            return []
        }

        var oneMonthFromNowComponents = DateComponents()
        oneMonthFromNowComponents.day = days

        guard
            let oneMonthFromNow = calendar.date(
                byAdding: oneMonthFromNowComponents, to: date, wrappingComponents: false
            )
        else {
            return []
        }

        let store = await eventStoreService.store
        let predicate = store.predicateForEvents(
            withStart: today,
            end: oneMonthFromNow,
            calendars: !calendars.isEmpty ? calendars : []
        )

        return store.events(matching: predicate).sorted(.orderedAscending).filter(filter)
    }

    func events(
        from calendars: [EKCalendar],
        limit count: Int = Int.max,
        where filter: ((EKEvent) -> Bool) = { _ in true },
        relativeTo date: Date
    ) async -> [EKEvent] {
        let calendar = Calendar.autoupdatingCurrent
        let store = await eventStoreService.store

        var consideredDays = 56
        var events = [EKEvent]()
        var currentDate = date
        let increment = 14

        while events.count < count, consideredDays > 0 {
            guard !calendars.isEmpty else {
                return []
            }
            guard let aWeekLater = calendar.date(
                byAdding: DateComponents(day: increment),
                to: currentDate,
                wrappingComponents: false
            )
            else {
                return []
            }

            let predicate = store.predicateForEvents(
                withStart: currentDate,
                end: aWeekLater,
                calendars: calendars
            )

            let fetchedEvents = store.events(matching: predicate).sorted(.orderedAscending)

            events = Array(Set(events).union(fetchedEvents)).sorted()

            currentDate = aWeekLater
            consideredDays -= increment
        }

        return events.filter(filter)
    }

    func events(
        from calendarIds: [String],
        during days: Int = 30,
        where filter: ((EKEvent) -> Bool) = { _ in true },
        relativeTo date: Date
    ) async -> [EKEvent] {
        let store = await eventStoreService.store
        let calendars = calendarIds.compactMap { id in
            store.calendar(withIdentifier: id)
        }
        return await events(from: calendars, during: days, where: filter, relativeTo: date)
    }
}
