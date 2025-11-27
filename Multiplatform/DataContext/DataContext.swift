//
//  DataContext.swift
//  Cami
//
//  Created by Guillaume Coquard on 15/11/23.
//

import Contacts
import EventKit
import SwiftUI

final class DataContext: @unchecked Sendable {
    static let shared: DataContext = .init()

    private let eventStoreService = EventStoreService.shared
    fileprivate let eventService = EventService()
    fileprivate let reminderService = ReminderService()
    fileprivate let birthdayService = BirthdayService()

    var contactStore: CNContactStore = .init()

    private(set) var allCalendars: [EKCalendar] = []
    private(set) var taskLists: [EKCalendar] = []

    private var observationTask: Task<Void, Never>?

    private init() {
        update()
        startObserving()
    }

    private func update() {
        allCalendars = getAllCalendarsForEvents()
        taskLists = getAllCalendarsForReminders()
    }

    private func startObserving() {
        observationTask = Task { [weak self] in
            guard let self else { return }
            for await _ in eventStoreService.storeChanges() {
                self.update()
            }
        }
    }

    private func getAllCalendarsForEvents() -> [EKCalendar] {
        eventStoreService.store.calendars(for: .event)
    }

    private func getAllCalendarsForReminders() -> [EKCalendar] {
        eventStoreService.store.calendars(for: .reminder)
    }

    var store: EKEventStore {
        eventStoreService.store
    }

    var eventStore: EKEventStore {
        eventStoreService.store
    }

    var calendars: [EKCalendar] {
        allCalendars.filter { $0.type != .birthday }
    }

    func get(calendar identifier: String) -> EKCalendar? {
        eventStoreService.store.calendar(withIdentifier: identifier)
    }
}

extension DataContext: Loggable {}

// MARK: Access Requests

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

extension DataContext {
    /// Creates an AsyncStream that emits EventKit store change notifications
    func eventStoreChanges() -> AsyncStream<Notification> {
        eventStoreService.storeChanges()
    }

    // MARK: - Service Access

    var _eventService: EventService { eventService }
    var _reminderService: ReminderService { reminderService }
    var _birthdayService: BirthdayService { birthdayService }
}
