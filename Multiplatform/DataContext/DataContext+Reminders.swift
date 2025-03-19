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
        where filter: ((EKReminder) -> Bool) = { _ in true }
    ) -> [EKReminder] {
        let taskLists = taskLists ?? self.taskLists

        eventStore.refreshSourcesIfNecessary()

        let predicate = eventStore.predicateForReminders(in: taskLists)
        let semaphor = DispatchSemaphore(value: 0)
        var reminders = [EKReminder]()

        Task {
            reminders = await withUnsafeContinuation { result in
                eventStore.fetchReminders(matching: predicate) { reminders in
                    if let reminders {
                        result.resume(returning: reminders)
                    } else {
                        result.resume(returning: [])
                    }
                }
            }
            semaphor.signal()
        }

        _ = semaphor.wait(timeout: .now() + 2)

        return reminders.filter(filter)
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

    func completeReminder(withIdentifier identifier: String) -> Bool {
        do {
            if let reminder = reminders(where: {$0.calendarItemIdentifier == identifier}).first {
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
}

enum ReminderError: Error {
    case failureToSave
}

extension [CalendarItem] {
    func dictionary() -> [Date: [CalendarItem]] {
        let sorted = self.sorted()
        var dictionary = [Date: [CalendarItem]]()
        for reminder in sorted {
            if dictionary[reminder.boundStart] == nil {
                dictionary[reminder.boundStart] = [reminder]
            } else {
                dictionary[reminder.boundStart]?.append(reminder)
            }
        }
        return dictionary
    }
}
