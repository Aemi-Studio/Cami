//
//  DataContext+Events.swift
//  Cami
//
//  Created by Guillaume Coquard on 26/01/25.
//

import EventKit
import Foundation

// MARK: - Events

extension DataContext {
    func event(for id: String) -> EKEvent? {
        eventStore.refreshSourcesIfNecessary()
        return eventStore.event(withIdentifier: id)
    }

    func events(
        from calendars: [EKCalendar]? = nil,
        during days: Int,
        where filter: ((EKEvent) -> Bool) = { _ in true },
        relativeTo date: Date
    ) -> [EKEvent] {
        let calendars = calendars ?? self.calendars

        eventStore.refreshSourcesIfNecessary()

        let calendar = Calendar.autoupdatingCurrent

        var todayComponent = DateComponents()
        todayComponent.day = 0

        guard let today = calendar.date(byAdding: todayComponent, to: date, wrappingComponents: false)
        else {
            return [EKEvent]()
        }

        var oneMonthFromNowComponents = DateComponents()
        oneMonthFromNowComponents.day = days

        guard
            let oneMonthFromNow = calendar.date(
                byAdding: oneMonthFromNowComponents, to: date, wrappingComponents: false
            )
        else {
            return [EKEvent]()
        }

        let predicate = eventStore.predicateForEvents(
            withStart: today,
            end: oneMonthFromNow,
            calendars: !calendars.isEmpty ? calendars : self.calendars
        )

        return eventStore.events(matching: predicate).sorted(.orderedAscending).filter(filter)
    }

    func events(
        from calendars: [EKCalendar],
        limit count: Int = Int.max,
        where _: ((EKEvent) -> Bool) = { _ in true },
        relativeTo date: Date
    ) -> [EKEvent] {
        eventStore.refreshSourcesIfNecessary()

        let calendar = Calendar.autoupdatingCurrent

        var resetDayComponent = DateComponents()
        resetDayComponent.day = 0

        var consideredDays = 56
        var events = [EKEvent]()
        var currentDate = date
        let increment = 14

        while events.count < count, consideredDays > 0 {
            guard !calendars.isEmpty else {
                log.error("No calendars provided.")
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

            let predicate = eventStore.predicateForEvents(
                withStart: currentDate,
                end: aWeekLater,
                calendars: calendars
            )

            let fetchedEvents = eventStore.events(matching: predicate).sorted(.orderedAscending)

            events = Array(Set(events).union(fetchedEvents)).sorted()

            currentDate = aWeekLater
            consideredDays -= increment
        }

        return events
    }

    func events(
        from calendars: [String],
        during days: Int = 30,
        where filter: ((EKEvent) -> Bool) = { _ in true },
        relativeTo date: Date
    ) -> [EKEvent] {
        events(from: calendars.asEKCalendars(), during: days, where: filter, relativeTo: date)
    }
}
