//
//  WidgetDataService.swift
//  Cami
//
//  Created by Guillaume Coquard on 28/09/25.
//

import EventKit
import Foundation

/// Service for fetching calendar data optimized for widgets.
@MainActor
final class WidgetDataService {
    private let eventStoreService = EventStoreService.shared

    init() {}

    func getEventsForWidget(
        calendars: [String],
        limit: Int = 20,
        referenceDate: Date = .now
    ) async -> [EKEvent] {
        let store = await eventStoreService.store
        let ekCalendars = calendars.compactMap { identifier in
            store.calendar(withIdentifier: identifier)
        }

        guard !ekCalendars.isEmpty else {
            return []
        }

        let endDate = Calendar.current.date(
            byAdding: .weekOfYear,
            value: 8,
            to: referenceDate
        ) ?? referenceDate

        let predicate = store.predicateForEvents(
            withStart: referenceDate,
            end: endDate,
            calendars: ekCalendars
        )

        return Array(store.events(matching: predicate)
            .sorted { $0.startDate < $1.startDate }
            .prefix(limit))
    }

    func getRemindersForWidget(
        calendars: [String]? = nil,
        limit: Int = 20
    ) async -> [EKReminder] {
        let store = await eventStoreService.store
        let ekCalendars: [EKCalendar] =
            if let calendars {
                calendars.compactMap { identifier in
                    store.calendar(withIdentifier: identifier)
                }
            } else {
                store.calendars(for: .reminder)
            }

        let predicate = store.predicateForReminders(in: ekCalendars)

        let reminders = await withCheckedContinuation { continuation in
            store.fetchReminders(matching: predicate) { reminders in
                continuation.resume(returning: reminders ?? [])
            }
        }

        let filtered = reminders
            .filter { !$0.isCompleted && $0.dueDateComponents?.date != nil }
            .sorted { lhs, rhs in
                guard let lhsDate = lhs.dueDateComponents?.date,
                      let rhsDate = rhs.dueDateComponents?.date
                else {
                    return false
                }
                return lhsDate < rhsDate
            }

        return Array(filtered.prefix(limit))
    }

    func getBirthdaysForWidget(
        referenceDate: Date = .now,
        days: Int = 90
    ) async -> [EKEvent] {
        let store = await eventStoreService.store
        let calendars = store.calendars(for: .event)
        let birthdayCalendar = calendars.first { $0.type == .birthday }

        guard let birthdayCalendar else {
            return []
        }

        let endDate = Calendar.current.date(
            byAdding: .day,
            value: days,
            to: referenceDate
        ) ?? referenceDate

        let predicate = store.predicateForEvents(
            withStart: referenceDate,
            end: endDate,
            calendars: [birthdayCalendar]
        )

        return store.events(matching: predicate)
            .sorted { $0.startDate < $1.startDate }
    }
}
