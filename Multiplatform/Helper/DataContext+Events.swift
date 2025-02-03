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
        from calendars: Calendars? = nil,
        during days: Int = 30,
        where filter: ((EKEvent) -> Bool) = { _ in true },
        relativeTo date: Date
    ) -> CItems {
        let calendars = calendars ?? self.calendars

        eventStore.refreshSourcesIfNecessary()

        let calendar = Calendar.autoupdatingCurrent

        var todayComponent = DateComponents()
        todayComponent.day = 0

        guard let today = calendar.date(byAdding: todayComponent, to: date, wrappingComponents: false)
        else { return Events() }

        var oneMonthFromNowComponents = DateComponents()
        oneMonthFromNowComponents.day = days

        guard
            let oneMonthFromNow = calendar.date(
                byAdding: oneMonthFromNowComponents, to: date, wrappingComponents: false
            )
        else { return Events() }

        let predicate = eventStore.predicateForEvents(
            withStart: today,
            end: oneMonthFromNow,
            calendars: !calendars.isEmpty ? calendars : self.calendars
        )

        return eventStore.events(matching: predicate).sorted(.orderedAscending).filter(filter)
    }

    func events(
        from calendars: [String],
        during days: Int = 30,
        where filter: ((EKEvent) -> Bool) = { _ in true },
        relativeTo date: Date
    ) -> CItems {
        events(from: calendars.asEKCalendars(), during: days, where: filter, relativeTo: date)
    }

    func events(
        from calendars: Calendars? = nil,
        during days: Int = 30,
        where filter: ((EKEvent) -> Bool) = { _ in true },
        relativeTo date: Date
    ) -> CIDict {
        events(from: calendars, during: days, where: filter, relativeTo: date)
            .mapped(relativeTo: date)
    }

    func events(
        from calendars: [String]? = nil,
        during days: Int = 30,
        where filter: ((EKEvent) -> Bool) = { _ in true },
        relativeTo date: Date
    ) -> CIDict {
        events(from: calendars?.asEKCalendars() ?? self.calendars, during: days, where: filter, relativeTo: date)
            .mapped(relativeTo: date)
    }

    func events(
        from calendars: [WidgetCalendarEntity] = WidgetCalendarEntity.allCalendars,
        during days: Int = 30,
        where filter: ((EKEvent) -> Bool) = { _ in true },
        relativeTo date: Date
    ) -> CIDict {
        events(from: calendars.map { $0.calendar }, during: days, where: filter, relativeTo: date)
    }
}
