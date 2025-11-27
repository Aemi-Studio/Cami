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
        let calendars = calendars ?? self.taskLists
        return await reminderService.reminders(from: calendars, where: filter)
    }

    /// Returns reminders due on a specific date that are not completed.
    func reminders(for date: Date) async -> [EKReminder] {
        await reminders(where: Filters.dueAndOpen(on: date).callable)
    }
}

extension DataContext {
    func createEvent() async -> EKEvent {
        EKEvent(eventStore: await store)
    }

    func createReminder(
        title: String,
        date: Date? = nil,
        priority: EKReminderPriority = .none,
        details: String? = nil,
        calendar: EKCalendar? = nil
    ) async throws(ReminderError) -> EKReminder {
        try await reminderService.createReminder(
            title: title,
            date: date,
            priority: priority,
            details: details,
            calendar: calendar
        )
    }

    func completeReminder(withIdentifier identifier: String) async -> Bool {
        await reminderService.completeReminder(withIdentifier: identifier)
    }
}
