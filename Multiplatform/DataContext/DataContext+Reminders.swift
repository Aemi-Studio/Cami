//
//  DataContext+Reminders.swift
//  Cami
//
//  Created by Guillaume Coquard on 26/01/25.
//

import EventKit
import Foundation

// MARK: - Reminders

extension DataContext {
    func reminders(
        from calendars: [EKCalendar]? = nil,
        where filter: ((EKReminder) -> Bool) = { _ in true }
    ) async -> [EKReminder] {
        let calendars = calendars ?? self.calendars

        eventStore.refreshSourcesIfNecessary()

        let predicate = eventStore.predicateForReminders(
            in: calendars
        )

        let reminders = await withUnsafeContinuation { result in
            eventStore.fetchReminders(matching: predicate) { reminders in
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
        from taskLists: [EKCalendar]? = nil,
        where filter: (@escaping (EKReminder) -> Bool) = { _ in true },
        operation: @escaping ([EKReminder]) -> Void
    ) {
        let taskLists = taskLists ?? self.taskLists

        eventStore.refreshSourcesIfNecessary()

        let predicate = eventStore.predicateForReminders(in: taskLists)

        eventStore.fetchReminders(matching: predicate) { reminders in
            if let reminders {
                operation(reminders.filter(filter))
            }
        }
    }
}

extension DataContext {
    func createReminder(
        title: String,
        date: Date? = nil,
        priority: EKReminderPriority = .none,
        details: String? = nil,
        calendar: EKCalendar? = nil
    ) throws(ReminderError) -> EKReminder {
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = title

        if let calendar {
            reminder.calendar = calendar
        } else {
            reminder.calendar = eventStore.defaultCalendarForNewReminders()
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
            try eventStore.save(reminder, commit: true)
            return reminder
        } catch {
            log.error("Failed to save reminder: \(error.localizedDescription)")
            throw .failureToSave
        }
    }

    private func completeReminder(_ reminder: EKReminder?) -> Bool {
        do {
            if let reminder {
                reminder.isCompleted = true
                try eventStore.save(reminder, commit: true)
                log.info("Succeed to complete reminder: \(reminder.title)")
                return true
            }
        } catch {
            log.error("Failed to complete reminder: \(error.localizedDescription)")
        }
        return false
    }

    func completeReminder(withIdentifier identifier: String) async -> Bool {
        await withCheckedContinuation { continuation in
            reminders { reminder in
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
