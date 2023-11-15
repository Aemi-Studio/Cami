//
//  CalendarStore.swift
//  Cami
//
//  Created by Guillaume Coquard on 05/11/23.
//

import Foundation
import EventKit

class CalendarHandler {

    public static var store: EKEventStore = EKEventStore()

    public static func request() async -> EKAuthorizationSet {
        do {
            return EKAuthorizationSet([
                try await store.requestFullAccessToEvents() ? .events : .none,
                try await store.requestFullAccessToReminders() ? .reminders : .none
            ])
        } catch {
            print(error.localizedDescription)
        }
        return .none
    }

    public static func events() -> (EKEventMap, EKEventList) {

        let calendar = Calendar.autoupdatingCurrent

        var events: EKEventList = []
        var birthdays: EKEventList = []

        var todayComponent = DateComponents()
        todayComponent.day = 0
        let today = calendar.date(
            byAdding: todayComponent,
            to: Date(),
            wrappingComponents: false
        )


        // Create the end date components.
        var oneMonthFromNowComponents = DateComponents()
        oneMonthFromNowComponents.day = 30
        let oneMonthFromNow = calendar.date(
            byAdding: oneMonthFromNowComponents,
            to: Date(),
            wrappingComponents: false
        )


        // Create the predicate from the event store's instance method.
        var predicate: NSPredicate? = nil
        if let anAgo = today, let aNow = oneMonthFromNow {
            predicate = CalendarHandler.store.predicateForEvents(
                withStart: anAgo,
                end: aNow,
                calendars: nil
            )
        }
        // Fetch all events that match the predicate.
        if let aPredicate = predicate {
            events = CalendarHandler.store.events(matching: aPredicate)
        }
        var eventsDictionary: EKEventMap = [:]
        for event in events {
            let resetDate = event.startDate.zero
            if event.calendar.type == .birthday {
                birthdays.append( event )
            } else if eventsDictionary[resetDate] != nil {
                eventsDictionary[resetDate]?.append(event)
            } else {
                eventsDictionary[resetDate] = [event]
            }
        }
        return (eventsDictionary, birthdays.sortedEventByAscendingDate())
    }

}
