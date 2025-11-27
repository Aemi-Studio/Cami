//
//  DayStore.swift
//  Cami
//
//  Created by Guillaume Coquard on 26/11/25.
//

import EventKit
import Foundation
import OSLog

/// Observable store providing reactive, filtered data for day views.
///
/// DayStore is the primary interface for UI components that display
/// calendar events and reminders. It:
/// - Manages the currently selected date
/// - Provides filtered events/reminders based on AppSettings
/// - Handles date navigation
/// - Coordinates with CalendarStore for data fetching
@Observable
@MainActor
final class DayStore {
    static let shared = DayStore()

    private let logger = Logger(subsystem: "dev.music.cami", category: "DayStore")
    private let calendarStore: CalendarStore
    private let settings: AppSettings

    // MARK: - Published State

    /// The currently selected date
    private(set) var selectedDate: Date = .now.zero

    /// Events for the selected date (filtered by calendar selection)
    private(set) var events: [EKEvent] = []

    /// Reminders for the selected date (filtered by calendar selection)
    private(set) var reminders: [EKReminder] = []

    /// Overdue reminders (not completed, due before today)
    private(set) var overdueReminders: [EKReminder] = []

    /// Whether data is currently being loaded
    private(set) var isLoading = false

    /// Error state if loading fails
    private(set) var error: Error?

    // MARK: - Computed Properties

    /// Whether the selected date is today
    var isViewingToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    /// Combined and sorted items for display
    var combinedItems: [CalendarDisplayItem] {
        var items: [CalendarDisplayItem] = []

        // Add events
        items.append(contentsOf: events.map { CalendarDisplayItem.event($0) })

        // Add reminders
        items.append(contentsOf: reminders.map { CalendarDisplayItem.reminder($0) })

        // Sort by start time, then by title
        return items.sorted { lhs, rhs in
            let lhsDate = lhs.startDate ?? .distantPast
            let rhsDate = rhs.startDate ?? .distantPast

            if lhsDate != rhsDate {
                return lhsDate < rhsDate
            }
            return (lhs.title ?? "") < (rhs.title ?? "")
        }
    }

    /// Whether events should be displayed (from settings)
    var showEvents: Bool {
        get async {
            await settings.showEvents
        }
    }

    /// Whether reminders should be displayed (from settings)
    var showReminders: Bool {
        get async {
            await settings.showReminders
        }
    }

    // MARK: - Subscriptions

    private var observationTask: Task<Void, Never>?

    // MARK: - Initialization

    private init(calendarStore: CalendarStore = .shared, settings: AppSettings = .shared) {
        self.calendarStore = calendarStore
        self.settings = settings
    }

    /// Starts observing store changes and loads initial data
    func startObserving() {
        // Subscribe to CalendarStore changes
        observationTask = Task { [weak self] in
            guard let self else { return }
            for await change in await calendarStore.storeChanges() {
                await self.handleStoreChange(change)
            }
        }

        // Load initial data
        Task {
            await refresh()
        }

        logger.info("DayStore started observing")
    }

    // MARK: - Navigation

    /// Selects a specific date and loads its data
    func selectDate(_ date: Date) async {
        let normalizedDate = date.zero
        guard normalizedDate != selectedDate else { return }

        selectedDate = normalizedDate
        await refresh()

        // Prefetch surrounding days
        Task.detached { [weak self] in
            guard let self else { return }
            await self.calendarStore.prefetch(around: normalizedDate)
        }
    }

    /// Navigates to today's date
    func navigateToToday() async {
        await selectDate(.now)
    }

    /// Navigates by a number of days from the current selection
    func navigateByDays(_ offset: Int) async {
        guard let newDate = Calendar.current.date(byAdding: .day, value: offset, to: selectedDate) else {
            return
        }
        await selectDate(newDate)
    }

    /// Navigates to the next day
    func navigateToNextDay() async {
        await navigateByDays(1)
    }

    /// Navigates to the previous day
    func navigateToPreviousDay() async {
        await navigateByDays(-1)
    }

    // MARK: - Data Loading

    /// Refreshes data for the current selected date
    func refresh() async {
        isLoading = true
        error = nil

        async let fetchedEvents = calendarStore.events(for: selectedDate)
        async let fetchedReminders = calendarStore.reminders(for: selectedDate)
        async let fetchedOverdue = calendarStore.overdueReminders()

        events = await fetchedEvents
        reminders = await fetchedReminders
        overdueReminders = await fetchedOverdue

        logger.debug("Loaded \(self.events.count) events, \(self.reminders.count) reminders for \(self.selectedDate)")
        isLoading = false
    }

    /// Refreshes data for a specific date without changing selection
    func refreshDate(_ date: Date) async {
        let normalizedDate = date.zero

        if normalizedDate == selectedDate {
            await refresh()
        } else {
            // Just invalidate the cache for that date
            await calendarStore.invalidateCache(for: normalizedDate)
        }
    }

    // MARK: - Visibility Toggles

    /// Toggles event visibility
    func toggleShowEvents() async {
        let current = await settings.showEvents
        await settings.setShowEvents(!current)
    }

    /// Toggles reminder visibility
    func toggleShowReminders() async {
        let current = await settings.showReminders
        await settings.setShowReminders(!current)
    }

    // MARK: - Private Handlers

    private func handleStoreChange(_ change: CalendarStore.StoreChange) async {
        switch change {
        case .calendarsUpdated, .cacheInvalidated:
            await refresh()

        case .eventsUpdated(let date):
            if date.zero == selectedDate {
                events = await calendarStore.events(for: selectedDate)
            }

        case .remindersUpdated(let date):
            if date.zero == selectedDate {
                reminders = await calendarStore.reminders(for: selectedDate)
            }
        }
    }
}

// MARK: - CalendarDisplayItem

/// Unified representation of calendar items for display
enum CalendarDisplayItem: Identifiable {
    case event(EKEvent)
    case reminder(EKReminder)

    var id: String {
        switch self {
        case .event(let event):
            return "event-\(event.eventIdentifier ?? UUID().uuidString)"
        case .reminder(let reminder):
            return "reminder-\(reminder.calendarItemIdentifier)"
        }
    }

    var title: String? {
        switch self {
        case .event(let event):
            return event.title
        case .reminder(let reminder):
            return reminder.title
        }
    }

    var startDate: Date? {
        switch self {
        case .event(let event):
            return event.startDate
        case .reminder(let reminder):
            return reminder.dueDateComponents?.date
        }
    }

    var endDate: Date? {
        switch self {
        case .event(let event):
            return event.endDate
        case .reminder:
            return nil
        }
    }

    var calendar: EKCalendar? {
        switch self {
        case .event(let event):
            return event.calendar
        case .reminder(let reminder):
            return reminder.calendar
        }
    }

    var isAllDay: Bool {
        switch self {
        case .event(let event):
            return event.isAllDay
        case .reminder:
            return false
        }
    }

    var isCompleted: Bool {
        switch self {
        case .event:
            return false
        case .reminder(let reminder):
            return reminder.isCompleted
        }
    }
}

