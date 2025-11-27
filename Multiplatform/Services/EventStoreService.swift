//
//  EventStoreService.swift
//  Cami
//
//  Created by Guillaume Coquard on 28/09/25.
//

import EventKit
import Foundation

final class EventStoreService: @unchecked Sendable {
    static let shared = EventStoreService()

    private let eventStore = EKEventStore()
    private var lastRefreshTime: Date = .distantPast
    private let refreshInterval: TimeInterval = 30
    private let refreshQueue = DispatchQueue(label: "eventstore.refresh", qos: .utility)

    private init() {}

    var store: EKEventStore {
        refreshIfNeeded()
        return eventStore
    }

    private func refreshIfNeeded() {
        let now = Date()
        if now.timeIntervalSince(lastRefreshTime) > refreshInterval {
            refreshQueue.async { [weak self] in
                self?.eventStore.refreshSourcesIfNecessary()
                self?.lastRefreshTime = now
            }
        }
    }

    func requestCalendarsAccess() async throws {
        try await eventStore.requestFullAccessToEvents()
    }

    func requestRemindersAccess() async throws {
        try await eventStore.requestFullAccessToReminders()
    }

    /// Creates an AsyncStream that emits EventKit store change notifications
    func storeChanges() -> AsyncStream<Notification> {
        AsyncStream { continuation in
            let observer = NotificationCenter.default.addObserver(
                forName: .EKEventStoreChanged,
                object: nil,
                queue: .main
            ) { notification in
                continuation.yield(notification)
            }
            continuation.onTermination = { _ in
                NotificationCenter.default.removeObserver(observer)
            }
        }
    }
}
