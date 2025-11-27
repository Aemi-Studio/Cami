//
//  DataContext.swift
//  Cami
//
//  Created by Guillaume Coquard on 15/11/23.
//

import Contacts
import EventKit
import SwiftUI

/// Central data context for accessing EventKit calendars, events, and reminders.
///
/// DataContext coordinates access to the EventStoreService and provides
/// cached calendar data for UI consumption.
@MainActor
final class DataContext {
    static let shared = DataContext()

    private let eventStoreService = EventStoreService.shared
    let eventService: EventService
    let reminderService: ReminderService
    let birthdayService: BirthdayService

    let contactStore = CNContactStore()

    private(set) var allCalendars: [EKCalendar] = []
    private(set) var taskLists: [EKCalendar] = []

    private var observationTask: Task<Void, Never>?

    private init() {
        self.eventService = EventService()
        self.reminderService = ReminderService()
        self.birthdayService = BirthdayService()

        Task {
            await update()
            startObserving()
        }
    }

    private func update() async {
        allCalendars = await getAllCalendarsForEvents()
        taskLists = await getAllCalendarsForReminders()
    }

    private func startObserving() {
        observationTask = Task { [weak self] in
            guard let self else { return }
            for await _ in eventStoreService.storeChanges() {
                await self.update()
            }
        }
    }

    private func getAllCalendarsForEvents() async -> [EKCalendar] {
        await eventStoreService.store.calendars(for: .event)
    }

    private func getAllCalendarsForReminders() async -> [EKCalendar] {
        await eventStoreService.store.calendars(for: .reminder)
    }

    var store: EKEventStore {
        get async {
            await eventStoreService.store
        }
    }

    var calendars: [EKCalendar] {
        allCalendars.filter { $0.type != .birthday }
    }

    func calendar(withIdentifier identifier: String) async -> EKCalendar? {
        await eventStoreService.store.calendar(withIdentifier: identifier)
    }
}

extension DataContext: Loggable {}

// MARK: - Access Requests

extension DataContext {
    func requestCalendarsAccess() async {
        do {
            try await eventStoreService.requestCalendarsAccess()
        } catch {
            logger.error("Failed to request full calendar access: \(error.localizedDescription)")
        }
    }

    func requestRemindersAccess() async {
        do {
            try await eventStoreService.requestRemindersAccess()
        } catch {
            logger.error("Failed to request full reminders access: \(error.localizedDescription)")
        }
    }

    func requestContactsAccess() async {
        do {
            try await contactStore.requestAccess(for: .contacts)
        } catch {
            logger.error("Failed to request contacts access: \(error.localizedDescription)")
        }
    }
}

// MARK: - Environment Value

extension EnvironmentValues {
    @Entry var data: DataContext!
}

// MARK: - Store Changes

extension DataContext {
    /// Creates an AsyncStream that emits when the EventKit store changes.
    /// This is a nonisolated static method that can be called from any context.
    nonisolated static func eventStoreChanges() -> AsyncStream<Void> {
        EventStoreService.shared.storeChanges()
    }
}
