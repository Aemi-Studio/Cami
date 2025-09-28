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
        return await _reminderService.reminders(from: calendars, where: filter)
    }

    func reminders(
        from taskLists: [EKCalendar]? = nil,
        where filter: (@escaping (EKReminder) -> Bool) = { _ in true },
        operation: @escaping ([EKReminder]) -> Void
    ) {
        let taskLists = taskLists ?? self.taskLists
        _reminderService.reminders(from: taskLists, where: filter, operation: operation)
    }
}

extension DataContext {
    func createEvent() -> EKEvent {
        EKEvent(eventStore: eventStore)
    }

    func createReminder(
        title: String,
        date: Date? = nil,
        priority: EKReminderPriority = .none,
        details: String? = nil,
        calendar: EKCalendar? = nil
    ) throws(ReminderError) -> EKReminder {
        return try _reminderService.createReminder(
            title: title,
            date: date,
            priority: priority,
            details: details,
            calendar: calendar
        )
    }

    func completeReminder(withIdentifier identifier: String) async -> Bool {
        return await _reminderService.completeReminder(withIdentifier: identifier)
    }
}
