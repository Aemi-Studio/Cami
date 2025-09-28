//
//  WidgetDataService.swift
//  Cami
//
//  Created by Guillaume Coquard on 28/09/25.
//

import EventKit
import Foundation

final class WidgetDataService: @unchecked Sendable {
    private let eventStoreService = EventStoreService.shared

    init() {}

    func getEventsForWidget(
        calendars: [String],
        limit: Int = 20,
        referenceDate: Date = .now
    ) -> [EKEvent] {
        let ekCalendars = calendars.compactMap { identifier in
            eventStoreService.store.calendar(withIdentifier: identifier)
        }

        guard !ekCalendars.isEmpty else { return [] }

        let endDate = Calendar.current.date(
            byAdding: .weekOfYear,
            value: 8,
            to: referenceDate
        ) ?? referenceDate

        let predicate = eventStoreService.store.predicateForEvents(
            withStart: referenceDate,
            end: endDate,
            calendars: ekCalendars
        )

        return Array(eventStoreService.store.events(matching: predicate)
            .sorted { $0.startDate < $1.startDate }
            .prefix(limit))
    }

    func getRemindersForWidget(
        calendars: [String]? = nil,
        limit: Int = 20,
        operation: @escaping ([EKReminder]) -> Void
    ) {
        let ekCalendars: [EKCalendar]
        if let calendars = calendars {
            ekCalendars = calendars.compactMap { identifier in
                eventStoreService.store.calendar(withIdentifier: identifier)
            }
        } else {
            ekCalendars = eventStoreService.store.calendars(for: .reminder)
        }

        let predicate = eventStoreService.store.predicateForReminders(in: ekCalendars)

        eventStoreService.store.fetchReminders(matching: predicate) { reminders in
            let filtered = (reminders ?? [])
                .filter { !$0.isCompleted && $0.dueDateComponents?.date != nil }
                .sorted { lhs, rhs in
                    guard let lhsDate = lhs.dueDateComponents?.date,
                          let rhsDate = rhs.dueDateComponents?.date else {
                        return false
                    }
                    return lhsDate < rhsDate
                }

            operation(Array(filtered.prefix(limit)))
        }
    }

    func getBirthdaysForWidget(
        referenceDate: Date = .now,
        days: Int = 90
    ) -> [EKEvent] {
        let calendars = eventStoreService.store.calendars(for: .event)
        let birthdayCalendar = calendars.first { $0.type == .birthday }

        guard let birthdayCalendar = birthdayCalendar else { return [] }

        let endDate = Calendar.current.date(
            byAdding: .day,
            value: days,
            to: referenceDate
        ) ?? referenceDate

        let predicate = eventStoreService.store.predicateForEvents(
            withStart: referenceDate,
            end: endDate,
            calendars: [birthdayCalendar]
        )

        return eventStoreService.store.events(matching: predicate)
            .sorted { $0.startDate < $1.startDate }
    }
}