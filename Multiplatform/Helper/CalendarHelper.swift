//
//  CalendarStore.swift
//  Cami
//
//  Created by Guillaume Coquard on 05/11/23.
//

import Foundation
import EventKit
import OSLog

struct CalendarHelper {

    static let store: EKEventStore = .init()

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
            let result = try await Self.store.requestFullAccessToEvents()
            Logger.perms.info("CalendarHelper -> \(String(describing: result))")
            return result ? .calendars : .restrictedCalendars
        } catch {
            Logger.perms.error("\(String(describing: error))")
        }
        return .none
    }

    public static func requestAccess(
        _ callback: @escaping (PermissionSet) -> Void
    ) {
        Self.store.requestFullAccessToEvents { result, error in
            if error != nil {
                Logger.perms.error("\(String(describing: error))")
                callback(.none)
            } else {
                Logger.perms.error("CalendarHelper -> \(String(describing: result))")
                callback(result ? .calendars : .none)
            }
        }
        Self.store.refreshSourcesIfNecessary()
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

        Self.store.refreshSourcesIfNecessary()

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
            predicate = Self.store.predicateForEvents(
                withStart: anAgo,
                end: aNow,
                calendars: calendars.count > 0 ? calendars : CamiHelper.allCalendars
            )
        }

        // Fetch all events that match the predicate.
        if let aPredicate = predicate {
            events = Self.store
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

        Self.store.refreshSourcesIfNecessary()

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
            predicate = Self.store.predicateForEvents(
                withStart: anAgo,
                end: aNow,
                calendars: CamiHelper.birthdayCalendar != nil ? [CamiHelper.birthdayCalendar!] : []
            )
        }

        // Fetch all events that match the predicate.
        if let aPredicate = predicate {
            return Self.store
                .events(matching: aPredicate)
                .sorted(.orderedAscending)
        }

        return Events()
    }

}
