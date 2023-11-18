//
//  CalendarStore.swift
//  Cami
//
//  Created by Guillaume Coquard on 05/11/23.
//

import Foundation
import EventKit

final class CalendarHelper {

    public static var authorizationStatus: Bool {
        let authorizationStatus: EKAuthorizationStatus = EKEventStore.authorizationStatus(for: .event)
        return switch authorizationStatus {
            case .fullAccess:
                true
            default:
                false
        }
    }

    public static func requestAccess(
        store: EKEventStore = CamiHelper.eventStore
    ) async -> AuthSet {
        do {
            return try await store.requestFullAccessToEvents() ? .calendars : .none
        } catch {
            print(error.localizedDescription)
        }
        return .none
    }

    public static func requestAccess(
        store: EKEventStore = CamiHelper.eventStore,
        _ callback: @escaping (AuthSet) -> Void
    ) {
        store.requestFullAccessToEvents() { result, error in
            if error != nil {
#if DEBUG
                print(error!.localizedDescription)
#endif
                callback(.none)
            } else {
                callback(result ? .calendars : .none)
            }
        }
    }

    public static func events(
        store: EKEventStore = CamiHelper.eventStore,
        from calendars: [String] = CamiHelper.allCalendars.asIdentifiers,
        during days: Int = 30,
        where filter: ((EKEvent) -> Bool)? = nil,
        relativeTo date: Date = Date.now
    ) -> EventDict {

        let calendar = Calendar.autoupdatingCurrent
        let ekCalendars: [EKCalendar] = calendars.asEKCalendars(with: store)

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
        var predicate: NSPredicate? = nil
        if let anAgo = today, let aNow = oneMonthFromNow {
            predicate = store.predicateForEvents(
                withStart: anAgo,
                end: aNow,
                calendars: ekCalendars.count > 0 ? ekCalendars : CamiHelper.allCalendars
            )
        }

        // Fetch all events that match the predicate.
        if let aPredicate = predicate {
            events = store.events(matching: aPredicate).sortedEventByAscendingDate()
        }

        if filter != nil {
            events = events.filter(filter!)
        }

        var eventsDictionary: EventDict = [:]

        for event in events {
            if event.spansMore(than: date) {
                let theseDaysKey = date.addingTimeInterval(-86400).zero;
                eventsDictionary.append(to: theseDaysKey, event)
            } else {
                let resetDate = event.startDate.zero
                eventsDictionary.append(to: event.startDate.zero, event)
            }
        }

        return eventsDictionary
    }

    public static func birthdays(
        store: EKEventStore = CamiHelper.eventStore,
        days: Int = 365
    ) -> Events {

        let calendar = Calendar.autoupdatingCurrent

        var todayComponent = DateComponents()
        todayComponent.day = 0
        let today = calendar.date(
            byAdding: todayComponent,
            to: Date(),
            wrappingComponents: false
        )

        // Create the end date components.
        var oneMonthFromNowComponents = DateComponents()
        oneMonthFromNowComponents.day = days
        let oneMonthFromNow = calendar.date(
            byAdding: oneMonthFromNowComponents,
            to: Date(),
            wrappingComponents: false
        )

        // Create the predicate from the event store's instance method.
        var predicate: NSPredicate? = nil
        if let anAgo = today, let aNow = oneMonthFromNow {
            predicate = store.predicateForEvents(
                withStart: anAgo,
                end: aNow,
                calendars: CamiHelper.birthdayCalendar != nil ? [CamiHelper.birthdayCalendar!] : []
            )
        }

        // Fetch all events that match the predicate.
        if let aPredicate = predicate {
            return store.events(matching: aPredicate).sortedEventByAscendingDate()
        }

        return Events()
    }

}
