//
//  CalendarStore.swift
//  Cami
//
//  Created by Guillaume Coquard on 26/11/25.
//

import Combine
import EventKit
import Foundation
import OSLog

/// Thread-safe store for calendar data with intelligent caching.
///
/// CalendarStore is the single source of truth for:
/// - Available calendars (event calendars and task lists)
/// - Cached events and reminders by date
/// - Filtered data based on AppSettings calendar selection
actor CalendarStore {
    static let shared = CalendarStore()

    private let logger = Logger(subsystem: "dev.music.cami", category: "CalendarStore")
    private let dataContext: DataContext
    private let settings: AppSettings

    // MARK: - Cache

    private var eventCache: [Date: [EKEvent]] = [:]
    private var reminderCache: [Date: [EKReminder]] = [:]
    private var overdueRemindersCache: [EKReminder]?
    private var openRemindersCache: [EKReminder]?

    /// Maximum number of days to keep in cache
    private let maxCacheDays = 60

    // MARK: - Publishers

    private nonisolated(unsafe) let _storeChanged = PassthroughSubject<StoreChange, Never>()
    nonisolated var storeChanged: AnyPublisher<StoreChange, Never> {
        _storeChanged.eraseToAnyPublisher()
    }

    enum StoreChange: Sendable {
        case calendarsUpdated
        case eventsUpdated(Date)
        case remindersUpdated(Date)
        case cacheInvalidated
    }

    // MARK: - Subscriptions

    private var cancellables: Set<AnyCancellable> = []
    private var isSubscribed = false

    // MARK: - Initialization

    private init(dataContext: DataContext = .shared, settings: AppSettings = .shared) {
        self.dataContext = dataContext
        self.settings = settings
    }

    /// Starts listening for EventKit and settings changes
    func startObserving() {
        guard !isSubscribed else { return }
        isSubscribed = true

        // Subscribe to EventKit changes
        dataContext.publishEventStoreChanges()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { [weak self] in
                    await self?.handleEventStoreChange()
                }
            }
            .store(in: &cancellables)

        // Subscribe to settings changes
        settings.settingsChanged
            .receive(on: DispatchQueue.main)
            .sink { [weak self] change in
                Task { [weak self] in
                    await self?.handleSettingsChange(change)
                }
            }
            .store(in: &cancellables)

        // Initialize calendar selection with all calendars if not set
        Task {
            let calendarIDs = await MainActor.run {
                dataContext.calendars.map(\.calendarIdentifier)
            }
            await settings.initializeCalendarSelectionIfNeeded(with: calendarIDs)
        }

        logger.info("CalendarStore started observing")
    }

    // MARK: - Calendars

    /// All available event calendars (excluding birthday calendars)
    var calendars: [EKCalendar] {
        get async {
            await MainActor.run {
                dataContext.calendars
            }
        }
    }

    /// All available task lists (reminder calendars)
    var taskLists: [EKCalendar] {
        get async {
            await MainActor.run {
                dataContext.taskLists
            }
        }
    }

    /// Calendars grouped by source
    var calendarsBySource: [String: [EKCalendar]] {
        get async {
            let cals = await calendars
            return Dictionary(grouping: cals) { $0.source?.title ?? "Unknown" }
        }
    }

    /// Task lists grouped by source
    var taskListsBySource: [String: [EKCalendar]] {
        get async {
            let lists = await taskLists
            return Dictionary(grouping: lists) { $0.source?.title ?? "Unknown" }
        }
    }

    /// Currently selected calendar IDs from settings
    var selectedCalendarIDs: Set<String> {
        get async {
            await settings.selectedCalendarIDs
        }
    }

    /// Filters calendars to only selected ones
    func selectedCalendars() async -> [EKCalendar] {
        let all = await calendars
        let selectedIDs = await selectedCalendarIDs

        // If nothing selected, return all (first-time use)
        if selectedIDs.isEmpty {
            return all
        }

        return all.filter { selectedIDs.contains($0.calendarIdentifier) }
    }

    /// Filters task lists to only selected ones
    func selectedTaskLists() async -> [EKCalendar] {
        let all = await taskLists
        let selectedIDs = await selectedCalendarIDs

        if selectedIDs.isEmpty {
            return all
        }

        return all.filter { selectedIDs.contains($0.calendarIdentifier) }
    }

    // MARK: - Events

    /// Fetches events for a specific date, using cache when available
    func events(for date: Date) async -> [EKEvent] {
        let normalizedDate = date.zero

        if let cached = eventCache[normalizedDate] {
            return await filterEventsBySelectedCalendars(cached)
        }

        let fetched = await fetchEvents(for: normalizedDate)
        eventCache[normalizedDate] = fetched
        cleanupCacheIfNeeded()

        return await filterEventsBySelectedCalendars(fetched)
    }

    /// Fetches events for a date range
    func events(from startDate: Date, to endDate: Date) async -> [EKEvent] {
        var allEvents: [EKEvent] = []
        var currentDate = startDate.zero

        while currentDate <= endDate.zero {
            let dayEvents = await events(for: currentDate)
            allEvents.append(contentsOf: dayEvents)
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        return allEvents
    }

    private func fetchEvents(for date: Date) async -> [EKEvent] {
        await MainActor.run {
            dataContext.events(during: 1, relativeTo: date)
        }
    }

    private func filterEventsBySelectedCalendars(_ events: [EKEvent]) async -> [EKEvent] {
        let selectedIDs = await selectedCalendarIDs

        if selectedIDs.isEmpty {
            return events
        }

        return events.filter { event in
            guard let calendarID = event.calendar?.calendarIdentifier else {
                return false
            }
            return selectedIDs.contains(calendarID)
        }
    }

    // MARK: - Reminders

    /// Fetches reminders due on a specific date, using cache when available
    func reminders(for date: Date) async -> [EKReminder] {
        let normalizedDate = date.zero

        if let cached = reminderCache[normalizedDate] {
            return await filterRemindersBySelectedCalendars(cached)
        }

        let fetched = await fetchReminders(for: normalizedDate)
        reminderCache[normalizedDate] = fetched
        cleanupCacheIfNeeded()

        return await filterRemindersBySelectedCalendars(fetched)
    }

    /// Fetches overdue reminders (not completed, due before today)
    func overdueReminders() async -> [EKReminder] {
        if let cached = overdueRemindersCache {
            return await filterRemindersBySelectedCalendars(cached)
        }

        let fetched = await fetchOverdueReminders()
        overdueRemindersCache = fetched

        return await filterRemindersBySelectedCalendars(fetched)
    }

    /// Fetches all open (not completed) reminders
    func openReminders() async -> [EKReminder] {
        if let cached = openRemindersCache {
            return await filterRemindersBySelectedCalendars(cached)
        }

        let fetched = await fetchOpenReminders()
        openRemindersCache = fetched

        return await filterRemindersBySelectedCalendars(fetched)
    }

    private func fetchReminders(for date: Date) async -> [EKReminder] {
        await MainActor.run {
            // Note: This uses the synchronous version, we may need to adjust
        }
        // Use the async method from DataContext
        return await dataContext.reminders(for: date)
    }

    private func fetchOverdueReminders() async -> [EKReminder] {
        await dataContext.reminders(where: Filters.overdue.callable)
    }

    private func fetchOpenReminders() async -> [EKReminder] {
        await dataContext.reminders(where: Filters.open.callable)
    }

    private func filterRemindersBySelectedCalendars(_ reminders: [EKReminder]) async -> [EKReminder] {
        let selectedIDs = await selectedCalendarIDs

        if selectedIDs.isEmpty {
            return reminders
        }

        return reminders.filter { reminder in
            guard let calendarID = reminder.calendar?.calendarIdentifier else {
                return false
            }
            return selectedIDs.contains(calendarID)
        }
    }

    // MARK: - Cache Management

    /// Invalidates all cached data
    func invalidateCache() {
        eventCache.removeAll()
        reminderCache.removeAll()
        overdueRemindersCache = nil
        openRemindersCache = nil
        _storeChanged.send(.cacheInvalidated)
        logger.debug("Cache invalidated")
    }

    /// Invalidates cache for a specific date
    func invalidateCache(for date: Date) {
        let normalizedDate = date.zero
        eventCache.removeValue(forKey: normalizedDate)
        reminderCache.removeValue(forKey: normalizedDate)
        logger.debug("Cache invalidated for \(normalizedDate)")
    }

    /// Prefetches data for dates around the specified date
    func prefetch(around date: Date, range: Int = 7) async {
        let calendar = Calendar.current

        for offset in -range...range {
            guard let targetDate = calendar.date(byAdding: .day, value: offset, to: date) else {
                continue
            }

            let normalizedDate = targetDate.zero

            // Only fetch if not cached
            if eventCache[normalizedDate] == nil {
                let events = await fetchEvents(for: normalizedDate)
                eventCache[normalizedDate] = events
            }

            if reminderCache[normalizedDate] == nil {
                let reminders = await fetchReminders(for: normalizedDate)
                reminderCache[normalizedDate] = reminders
            }
        }

        cleanupCacheIfNeeded()
        logger.debug("Prefetched data for \(range * 2 + 1) days around \(date)")
    }

    private func cleanupCacheIfNeeded() {
        let today = Date.now.zero
        let calendar = Calendar.current

        // Remove entries outside the cache window
        eventCache = eventCache.filter { date, _ in
            guard let daysDiff = calendar.dateComponents([.day], from: today, to: date).day else {
                return false
            }
            return abs(daysDiff) <= maxCacheDays / 2
        }

        reminderCache = reminderCache.filter { date, _ in
            guard let daysDiff = calendar.dateComponents([.day], from: today, to: date).day else {
                return false
            }
            return abs(daysDiff) <= maxCacheDays / 2
        }
    }

    // MARK: - Change Handlers

    private func handleEventStoreChange() async {
        invalidateCache()
        _storeChanged.send(.calendarsUpdated)
        logger.info("EventKit store changed, cache invalidated")
    }

    private func handleSettingsChange(_ change: AppSettings.SettingsChange) async {
        switch change {
        case .calendarSelection:
            // Calendar selection changed - notify observers but keep cache
            // (cache stores all events, filtering happens on read)
            _storeChanged.send(.cacheInvalidated)
            logger.debug("Calendar selection changed")

        case .showEvents, .showReminders:
            // Visibility changes don't affect the cache
            break

        case .onboardingCompleted, .onboardingStepCompleted:
            // Onboarding changes don't affect calendar data
            break
        }
    }
}

