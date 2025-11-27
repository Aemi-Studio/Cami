//
//  ReminderService.swift
//  Cami
//
//  Created by Guillaume Coquard on 28/09/25.
//

import EventKit
import Foundation

/// Service for fetching and managing reminders.
@MainActor
final class ReminderService {
    private let eventStoreService = EventStoreService.shared

    init() {}

    func reminders(
        from calendars: [EKCalendar],
        where filter: ((EKReminder) -> Bool) = { _ in true }
    ) async -> [EKReminder] {
        let store = await eventStoreService.store
        let predicate = store.predicateForReminders(in: calendars)

        let reminders = await withCheckedContinuation { result in
            store.fetchReminders(matching: predicate) { reminders in
                result.resume(returning: reminders ?? [])
            }
        }

        return reminders.filter(filter)
    }

    func createReminder(
        title: String,
        date: Date? = nil,
        priority: EKReminderPriority = .none,
        details: String? = nil,
        calendar: EKCalendar? = nil
    ) async throws(ReminderError) -> EKReminder {
        let store = await eventStoreService.store
        let reminder = EKReminder(eventStore: store)
        reminder.title = title

        reminder.calendar =
            if let calendar {
                calendar
            } else {
                store.defaultCalendarForNewReminders()
            }

        if priority != .none {
            reminder.priority = Int(priority.rawValue)
        }

        if let details {
            reminder.notes = details
        }

        if let date {
            let alarm = EKAlarm(absoluteDate: date)
            reminder.addAlarm(alarm)
        }

        do {
            try store.save(reminder, commit: true)
            return reminder
        } catch {
            throw .failureToSave
        }
    }

    func completeReminder(_ reminder: EKReminder?) async -> Bool {
        guard let reminder else { return false }

        do {
            let store = await eventStoreService.store
            reminder.isCompleted = true
            try store.save(reminder, commit: true)
            return true
        } catch {
            return false
        }
    }

    func completeReminder(withIdentifier identifier: String) async -> Bool {
        let store = await eventStoreService.store
        let calendars = store.calendars(for: .reminder)
        let results = await reminders(from: calendars) { reminder in
            reminder.calendarItemIdentifier == identifier
        }
        return await completeReminder(results.first)
    }
}

enum ReminderError: Error {
    case failureToSave
}
