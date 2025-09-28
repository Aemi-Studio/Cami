//
//  ReminderService.swift
//  Cami
//
//  Created by Guillaume Coquard on 28/09/25.
//

import EventKit
import Foundation

final class ReminderService: @unchecked Sendable {
    private let eventStoreService = EventStoreService.shared

    init() {}

    func reminders(
        from calendars: [EKCalendar],
        where filter: ((EKReminder) -> Bool) = { _ in true }
    ) async -> [EKReminder] {
        let predicate = eventStoreService.store.predicateForReminders(in: calendars)

        let reminders = await withUnsafeContinuation { result in
            eventStoreService.store.fetchReminders(matching: predicate) { reminders in
                if let reminders {
                    result.resume(returning: reminders)
                } else {
                    result.resume(returning: [])
                }
            }
        }

        return reminders.filter(filter)
    }

    func reminders(
        from taskLists: [EKCalendar],
        where filter: (@escaping (EKReminder) -> Bool) = { _ in true },
        operation: @escaping ([EKReminder]) -> Void
    ) {
        let predicate = eventStoreService.store.predicateForReminders(in: taskLists)

        eventStoreService.store.fetchReminders(matching: predicate) { reminders in
            if let reminders {
                operation(reminders.filter(filter))
            }
        }
    }

    func createReminder(
        title: String,
        date: Date? = nil,
        priority: EKReminderPriority = .none,
        details: String? = nil,
        calendar: EKCalendar? = nil
    ) throws(ReminderError) -> EKReminder {
        let reminder = EKReminder(eventStore: eventStoreService.store)
        reminder.title = title

        reminder.calendar =
            if let calendar {
                calendar
            } else {
                eventStoreService.store.defaultCalendarForNewReminders()
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
            try eventStoreService.store.save(reminder, commit: true)
            return reminder
        } catch {
            throw .failureToSave
        }
    }

    func completeReminder(_ reminder: EKReminder?) -> Bool {
        do {
            if let reminder {
                reminder.isCompleted = true
                try eventStoreService.store.save(reminder, commit: true)
                return true
            }
        } catch {
            return false
        }
        return false
    }

    func completeReminder(withIdentifier identifier: String) async -> Bool {
        await withCheckedContinuation { continuation in
            reminders(from: eventStoreService.store.calendars(for: .reminder)) { reminder in
                reminder.calendarItemIdentifier == identifier
            } operation: { results in
                continuation.resume(
                    returning: self.completeReminder(results.first)
                )
            }
        }
    }
}

enum ReminderError: Error {
    case failureToSave
}
