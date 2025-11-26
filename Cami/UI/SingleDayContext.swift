//
//  SingleDayContext.swift
//  Cami
//
//  Created by Guillaume Coquard on 16/03/25.
//

import Combine
import EventKit
import SwiftUI

/// Loading state for day context
enum DayContextLoadingState: Equatable {
    case idle
    case loading
    case loaded
    case refreshing
}

/// Context for displaying calendar data for a specific day.
///
/// SingleDayContext is a lightweight wrapper that fetches data from CalendarStore
/// for a specific date. It handles local filtering and sorting for display.
@Observable
@MainActor
final class SingleDayContext {
    let date: Date

    private let calendarStore: CalendarStore
    private var cancellables: Set<AnyCancellable> = []

    /// Current loading state
    private(set) var loadingState: DayContextLoadingState = .idle

    /// Whether initial load is complete
    var isLoaded: Bool {
        loadingState == .loaded || loadingState == .refreshing
    }

    /// Whether currently loading (initial or refresh)
    var isLoading: Bool {
        loadingState == .loading || loadingState == .refreshing
    }

    private(set) var events: [EKEvent] = []
    private(set) var reminders: [EKReminder] = []
    private(set) var overdueReminders: [EKReminder] = []

    /// Combined and sorted items for display
    private(set) var combinedItems: [EKCalendarItem] = []

    /// Whether there are no items to display
    var isEmpty: Bool {
        combinedItems.isEmpty && isLoaded
    }

    /// Filtered events (already filtered by calendar selection in CalendarStore)
    var filteredEvents: [EKEvent] {
        events.sorted { $0.startDate < $1.startDate }
    }

    /// Filtered reminders (already filtered by calendar selection in CalendarStore)
    var filteredReminders: [EKReminder] {
        reminders.sorted {
            guard let lhsDue = $0.dueDateComponents?.date,
                  let rhsDue = $1.dueDateComponents?.date
            else {
                return false
            }
            return lhsDue < rhsDue
        }
    }

    init(for date: Date, calendarStore: CalendarStore = .shared) {
        self.date = date
        self.calendarStore = calendarStore
        subscribe()

        Task { [weak self] in
            await self?.initialLoad()
        }
    }

    private func subscribe() {
        calendarStore.storeChanged
            .receive(on: DispatchQueue.main)
            .sink { [weak self] change in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    switch change {
                    case .calendarsUpdated, .cacheInvalidated:
                        await refresh()
                    case .eventsUpdated(let updatedDate):
                        if updatedDate.zero == date.zero {
                            await refresh()
                        }
                    case .remindersUpdated(let updatedDate):
                        if updatedDate.zero == date.zero {
                            await refresh()
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }

    /// Initial load of data
    private func initialLoad() async {
        loadingState = .loading

        async let fetchedEvents = calendarStore.events(for: date)
        async let fetchedReminders = calendarStore.reminders(for: date)
        async let fetchedOverdue = calendarStore.overdueReminders()

        events = await fetchedEvents
        reminders = await fetchedReminders
        overdueReminders = await fetchedOverdue

        updateCombinedItems()
        loadingState = .loaded
    }

    /// Refresh data (maintains loaded state during refresh)
    func refresh() async {
        // Only show refreshing state if already loaded
        if isLoaded {
            loadingState = .refreshing
        }

        async let fetchedEvents = calendarStore.events(for: date)
        async let fetchedReminders = calendarStore.reminders(for: date)
        async let fetchedOverdue = calendarStore.overdueReminders()

        events = await fetchedEvents
        reminders = await fetchedReminders
        overdueReminders = await fetchedOverdue

        updateCombinedItems()
        loadingState = .loaded
    }

    private func updateCombinedItems() {
        let sortedEvents = filteredEvents
        let sortedReminders = filteredReminders

        var merged: [EKCalendarItem] = []
        var eventIndex = 0
        var reminderIndex = 0

        while eventIndex < sortedEvents.count || reminderIndex < sortedReminders.count {
            let event = eventIndex < sortedEvents.count ? sortedEvents[eventIndex] : nil
            let reminder = reminderIndex < sortedReminders.count ? sortedReminders[reminderIndex] : nil

            if let event, let reminder {
                let eventStart = event.startDate ?? .distantFuture
                let reminderDue = reminder.dueDateComponents?.date ?? .distantFuture

                if eventStart <= reminderDue {
                    merged.append(event)
                    eventIndex += 1
                } else {
                    merged.append(reminder)
                    reminderIndex += 1
                }
            } else if let event {
                merged.append(event)
                eventIndex += 1
            } else if let reminder {
                merged.append(reminder)
                reminderIndex += 1
            }
        }

        combinedItems = merged
    }
}
