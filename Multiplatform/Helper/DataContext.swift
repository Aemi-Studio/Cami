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

final class DataContext {
    static let shared: DataContext = .init()

    var eventStore: EKEventStore = .init()
    var contactStore: CNContactStore = .init()

    private(set) var allCalendars: Calendars = []
    private(set) var taskLists: Calendars = []

    private var cancellables: Set<AnyCancellable> = []

    private init() {
        update()
        subscribe()
    }

    private func update() {
        allCalendars = getAllCalendarsForEvents()
        taskLists = getAllCalendarsForReminders()
    }

    private func subscribe() {
        publishEventStoreChanges()
            .sink { [weak self] _ in
                self?.update()
            }
            .store(in: &cancellables)
    }

    private func getAllCalendarsForEvents() -> Calendars {
        eventStore.calendars(for: .event)
    }

    private func getAllCalendarsForReminders() -> Calendars {
        eventStore.calendars(for: .reminder)
    }

    var store: EKEventStore {
        eventStore
    }

    var calendars: Calendars {
        allCalendars.filter { $0.type != .birthday }
    }

    var allCalendarColors: [String: Color] {
        allCalendars.reduce(into: [String: Color]()) { result, calendar in
            if let color = calendar.cgColor {
                result[calendar.calendarIdentifier] = Color(cgColor: color)
            }
        }
    }

    var taskListsColors: [String: Color] {
        taskLists.reduce(into: [String: Color]()) { result, calendar in
            if let color = calendar.cgColor {
                result[calendar.calendarIdentifier] = Color(cgColor: color)
            }
        }
    }

    func get(calendar identifier: String) -> EKCalendar? {
        eventStore.calendar(withIdentifier: identifier)
    }

    func getCalendar(from calendarItem: EKCalendarItem) -> EKCalendar? {
        if let calendar = calendarItem.calendar {
            return eventStore.calendar(withIdentifier: calendar.calendarIdentifier)
        }
        return nil
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
