//
//  DataContext.swift
//  Cami
//
//  Created by Guillaume Coquard on 15/11/23.
//

import Combine
import Contacts
import EventKit
import SwiftUI

final class DataContext: @unchecked Sendable {
    static let shared: DataContext = .init()

    var eventStore: EKEventStore = .init()
    var contactStore: CNContactStore = .init()

    private(set) var allCalendars: [EKCalendar] = []
    private(set) var taskLists: [EKCalendar] = []

    private var cancellables: Set<AnyCancellable> = []

    private init() {
        update()
        subscribe()
    }

    private func update() {
        allCalendars = getAllCalendarsForEvents()
        taskLists = getAllCalendarsForReminders()
    }

    func subscribe() {
        publishEventStoreChanges()
            .sink { [weak self] _ in
                self?.update()
            }
            .store(in: &cancellables)
    }

    private func getAllCalendarsForEvents() -> [EKCalendar] {
        eventStore.calendars(for: .event)
    }

    private func getAllCalendarsForReminders() -> [EKCalendar] {
        eventStore.calendars(for: .reminder)
    }

    var store: EKEventStore {
        eventStore
    }

    var calendars: [EKCalendar] {
        allCalendars.filter { $0.type != .birthday }
    }

    func get(calendar identifier: String) -> EKCalendar? {
        eventStore.calendar(withIdentifier: identifier)
    }
}

extension DataContext: Loggable {}

// MARK: Access Requests

extension DataContext {
    public func requestCalendarsAccess() async {
        do {
            try await eventStore.requestFullAccessToEvents()
        } catch {
            log.error("Failed to request full calendar access: \(error.localizedDescription)")
        }
    }

    public func requestRemindersAccess() async {
        do {
            try await eventStore.requestFullAccessToReminders()
        } catch {
            log.error("Failed to request full reminders access: \(error.localizedDescription)")
        }
    }

    public func requestContactsAccess() async {
        do {
            try await contactStore.requestAccess(for: .contacts)
        } catch {
            log.error("Failed to request contacts access: \(error.localizedDescription)")
        }
    }
}

// MARK: - Environment Value

extension EnvironmentValues {
    @Entry var data: DataContext!
}

extension DataContext {
    func publishEventStoreChanges() -> AnyPublisher<Notification, Never> {
        NotificationCenter.default.publisher(for: .EKEventStoreChanged).eraseToAnyPublisher()
    }
}
