//
//  CalendarStore.swift
//  Cami
//
//  Created by Guillaume Coquard on 05/11/23.
//

import Foundation
import EventKit

struct CalendarHelper {

    public static var authorizationStatus: Bool {
        let authorizationStatus: EKAuthorizationStatus = EKEventStore.authorizationStatus(for: .event)
        return switch authorizationStatus {
        case .fullAccess:
            true
        default:
            false
        }
    }

    public static func requestAccess() async -> AuthSet {
        do {
            return try await EventHelper.store.requestFullAccessToEvents()
                ? .calendars
                : .restrictedCalendars
        } catch {
            print(error.localizedDescription)
        }
        return .none
    }

    public static func requestAccess(
        _ callback: @escaping (AuthSet) -> Void
    ) {
        EventHelper.store.requestFullAccessToEvents { result, error in
            if error != nil {
                callback(.none)
            } else {
                callback(result ? .calendars : .none)
            }
        }
        EventHelper.store.refreshSourcesIfNecessary()
    }

    public static func events(
        from calendars: [String] = CamiHelper.allCalendars.asIdentifiers,
        during days: Int = 30,
        where filter: ((EKEvent) -> Bool)? = nil,
        relativeTo date: Date
    ) -> Events {
        CalendarHelper.events(
            from: calendars.asEKCalendars(),
            during: days,
            where: filter,
            relativeTo: date
        )
    }

    public static func events(
        from calendars: Calendars = CamiHelper.allCalendars,
        during days: Int = 30,
        where filter: ((EKEvent) -> Bool)? = nil,
        relativeTo date: Date
    ) -> Events {

        EventHelper.store.refreshSourcesIfNecessary()

        let calendar = Calendar.autoupdatingCurrent

        var events: Events = []

        var todayComponent = DateComponents()
        todayComponent.day = 0
        let today = calendar.date(
            byAdding: todayComponent,
            to: date,
            wrappingComponents: false
        )

        // Create the end date components.
        var oneMonthFromNowComponents = DateComponents()
        oneMonthFromNowComponents.day = days
        let oneMonthFromNow = calendar.date(
            byAdding: oneMonthFromNowComponents,
            to: date,
            wrappingComponents: false
        )

        // Create the predicate from the event store's instance method.
        var predicate: NSPredicate?
        if let anAgo = today, let aNow = oneMonthFromNow {
            predicate = EventHelper.store.predicateForEvents(
                withStart: anAgo,
                end: aNow,
                calendars: calendars.count > 0 ? calendars : CamiHelper.allCalendars
            )
        }

        // Fetch all events that match the predicate.
        if let aPredicate = predicate {
            events = EventHelper.store
                .events(matching: aPredicate)
                .sorted(.orderedAscending)
        }

        if filter != nil {
            events = events.filter(filter!)
        }

        return events
    }

    public static func birthdays(
        from date: Date,
        during days: Int = 365
    ) -> Events {

        EventHelper.store.refreshSourcesIfNecessary()

        let calendar = Calendar.autoupdatingCurrent

        var todayComponent = DateComponents()
        todayComponent.day = 0
        let today = calendar.date(
            byAdding: todayComponent,
            to: date,
            wrappingComponents: false
        )

        // Create the end date components.
        var limit = DateComponents()
        limit.day = days
        let endDate = calendar.date(
            byAdding: limit,
            to: date,
            wrappingComponents: false
        )

        // Create the predicate from the event store's instance method.
        var predicate: NSPredicate?
        if let anAgo = today, let aNow = endDate {
            predicate = EventHelper.store.predicateForEvents(
                withStart: anAgo,
                end: aNow,
                calendars: CamiHelper.birthdayCalendar != nil ? [CamiHelper.birthdayCalendar!] : []
            )
        }

        // Fetch all events that match the predicate.
        if let aPredicate = predicate {
            return EventHelper.store
                .events(matching: aPredicate)
                .sorted(.orderedAscending)
        }

        return Events()
    }

}
