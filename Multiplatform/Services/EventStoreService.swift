//
//  EventStoreService.swift
//  Cami
//
//  Created by Guillaume Coquard on 28/09/25.
//

import EventKit
import Foundation

/// Thread-safe service for accessing EventKit's EKEventStore.
///
/// This actor manages the shared EKEventStore instance and handles
/// periodic refresh of sources to keep calendar data up-to-date.
actor EventStoreService {
    static let shared = EventStoreService()

    private let eventStore = EKEventStore()
    private var lastRefreshTime: Date = .distantPast
    private let refreshInterval: TimeInterval = 30

    private init() {}

    /// The underlying EKEventStore instance.
    /// Automatically refreshes sources if stale.
    var store: EKEventStore {
        refreshIfNeeded()
        return eventStore
    }

    private func refreshIfNeeded() {
        let now = Date()
        if now.timeIntervalSince(lastRefreshTime) > refreshInterval {
            eventStore.refreshSourcesIfNecessary()
            lastRefreshTime = now
        }
    }

    func requestCalendarsAccess() async throws {
        try await eventStore.requestFullAccessToEvents()
    }

    func requestRemindersAccess() async throws {
        try await eventStore.requestFullAccessToReminders()
    }

    /// Creates an AsyncStream that emits when the EventKit store changes.
    /// The stream yields Void values; the notification content is not used.
    nonisolated func storeChanges() -> AsyncStream<Void> {
        AsyncStream { continuation in
            let observer = NotificationCenter.default.addObserver(
                forName: .EKEventStoreChanged,
                object: nil,
                queue: .main
            ) { _ in
                continuation.yield(())
            }
            continuation.onTermination = { _ in
                NotificationCenter.default.removeObserver(observer)
            }
        }
    }
}
