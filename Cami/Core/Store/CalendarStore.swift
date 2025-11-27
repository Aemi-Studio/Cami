//
//  CalendarStore.swift
//  Cami
//
//  Created by Guillaume Coquard on 26/11/25.
//

import EventKit
import Foundation
import OSLog

/// Thread-safe store for calendar data with intelligent caching.
///
/// CalendarStore is the single source of truth for:
/// - Available calendars (event calendars and task lists)
/// - Cached events and reminders by date
/// - Filtered data based on AppSettings calendar selection
///
/// Caching Strategy:
/// - LRU-style eviction based on last access time
/// - Maximum 60 days of cached data
/// - Priority prefetching for visible dates
/// - Background refresh for stale entries
actor CalendarStore {
    static let shared = CalendarStore()

    private let logger = Logger(subsystem: "dev.music.cami", category: "CalendarStore")
    private let dataContext: DataContext
    private let settings: AppSettings

    // MARK: - Cache

    /// Cached events by date with metadata
    private var eventCache: [Date: CacheEntry<[EKEvent]>] = [:]

    /// Cached reminders by date with metadata
    private var reminderCache: [Date: CacheEntry<[EKReminder]>] = [:]

    /// Cached overdue reminders
    private var overdueRemindersCache: CacheEntry<[EKReminder]>?

    /// Cached open reminders
    private var openRemindersCache: CacheEntry<[EKReminder]>?

    /// Maximum number of days to keep in cache
    private let maxCacheDays = 60

    /// How long before a cache entry is considered stale (in seconds)
    private let staleThreshold: TimeInterval = 300 // 5 minutes

    /// Cache entry wrapper with metadata
    private struct CacheEntry<T> {
        let data: T
        let fetchedAt: Date
        var lastAccessedAt: Date

        var isStale: Bool {
            Date.now.timeIntervalSince(fetchedAt) > 300 // 5 minutes
        }

        init(data: T) {
            self.data = data
            self.fetchedAt = Date.now
            self.lastAccessedAt = Date.now
        }

        mutating func touch() {
            lastAccessedAt = Date.now
        }
    }

    // MARK: - Store Changes

    enum StoreChange: Sendable {
        case calendarsUpdated
        case eventsUpdated(Date)
        case remindersUpdated(Date)
        case cacheInvalidated
    }

    /// Continuations for store change streams
    private var continuations: [UUID: AsyncStream<StoreChange>.Continuation] = [:]

    /// Creates an AsyncStream that emits store changes
    func storeChanges() -> AsyncStream<StoreChange> {
        let (stream, continuation) = AsyncStream.makeStream(of: StoreChange.self)
        let id = UUID()
        continuations[id] = continuation
        continuation.onTermination = { [weak self] _ in
            Task { [weak self] in
                await self?.removeContinuation(id)
            }
        }
        return stream
    }

    private func removeContinuation(_ id: UUID) {
        continuations.removeValue(forKey: id)
    }

    /// Sends a change to all active continuations
    private func send(_ change: StoreChange) {
        for continuation in continuations.values {
            continuation.yield(change)
        }
    }

    // MARK: - Subscriptions

    private var observationTask: Task<Void, Never>?
    private var settingsObservationTask: Task<Void, Never>?
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
        observationTask = Task { [weak self] in
            guard let self else { return }
            for await _ in dataContext.eventStoreChanges() {
                await self.handleEventStoreChange()
            }
        }

        // Subscribe to settings changes
        settingsObservationTask = Task { [weak self] in
            guard let self else { return }
            for await change in await settings.settingsChanges() {
                await self.handleSettingsChange(change)
            }
        }

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

        // Check cache
        if var entry = eventCache[normalizedDate] {
            entry.touch()
            eventCache[normalizedDate] = entry

            // Refresh in background if stale
            if entry.isStale {
                Task { [weak self] in
                    await self?.refreshEvents(for: normalizedDate)
                }
            }

            return await filterEventsBySelectedCalendars(entry.data)
        }

        // Fetch and cache
        let fetched = await fetchEvents(for: normalizedDate)
        eventCache[normalizedDate] = CacheEntry(data: fetched)
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

    /// Refreshes events for a date in the background
    private func refreshEvents(for date: Date) async {
        let fetched = await fetchEvents(for: date)
        eventCache[date] = CacheEntry(data: fetched)
        send(.eventsUpdated(date))
        logger.debug("Background refreshed events for \(date)")
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

        // Check cache
        if var entry = reminderCache[normalizedDate] {
            entry.touch()
            reminderCache[normalizedDate] = entry

            // Refresh in background if stale
            if entry.isStale {
                Task { [weak self] in
                    await self?.refreshReminders(for: normalizedDate)
                }
            }

            return await filterRemindersBySelectedCalendars(entry.data)
        }

        // Fetch and cache
        let fetched = await fetchReminders(for: normalizedDate)
        reminderCache[normalizedDate] = CacheEntry(data: fetched)
        cleanupCacheIfNeeded()

        return await filterRemindersBySelectedCalendars(fetched)
    }

    /// Fetches overdue reminders (not completed, due before today)
    func overdueReminders() async -> [EKReminder] {
        if var entry = overdueRemindersCache {
            entry.touch()
            overdueRemindersCache = entry

            // Refresh in background if stale
            if entry.isStale {
                Task { [weak self] in
                    await self?.refreshOverdueReminders()
                }
            }

            return await filterRemindersBySelectedCalendars(entry.data)
        }

        let fetched = await fetchOverdueReminders()
        overdueRemindersCache = CacheEntry(data: fetched)

        return await filterRemindersBySelectedCalendars(fetched)
    }

    /// Fetches all open (not completed) reminders
    func openReminders() async -> [EKReminder] {
        if var entry = openRemindersCache {
            entry.touch()
            openRemindersCache = entry

            if entry.isStale {
                Task { [weak self] in
                    await self?.refreshOpenReminders()
                }
            }

            return await filterRemindersBySelectedCalendars(entry.data)
        }

        let fetched = await fetchOpenReminders()
        openRemindersCache = CacheEntry(data: fetched)

        return await filterRemindersBySelectedCalendars(fetched)
    }

    /// Refreshes reminders for a date in the background
    private func refreshReminders(for date: Date) async {
        let fetched = await fetchReminders(for: date)
        reminderCache[date] = CacheEntry(data: fetched)
        send(.remindersUpdated(date))
        logger.debug("Background refreshed reminders for \(date)")
    }

    /// Refreshes overdue reminders in the background
    private func refreshOverdueReminders() async {
        let fetched = await fetchOverdueReminders()
        overdueRemindersCache = CacheEntry(data: fetched)
        logger.debug("Background refreshed overdue reminders")
    }

    /// Refreshes open reminders in the background
    private func refreshOpenReminders() async {
        let fetched = await fetchOpenReminders()
        openRemindersCache = CacheEntry(data: fetched)
        logger.debug("Background refreshed open reminders")
    }

    private func fetchReminders(for date: Date) async -> [EKReminder] {
        await dataContext.reminders(for: date)
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
        send(.cacheInvalidated)
        logger.debug("Cache invalidated")
    }

    /// Invalidates cache for a specific date
    func invalidateCache(for date: Date) {
        let normalizedDate = date.zero
        eventCache.removeValue(forKey: normalizedDate)
        reminderCache.removeValue(forKey: normalizedDate)
        logger.debug("Cache invalidated for \(normalizedDate)")
    }

    /// Prefetches data for dates around the specified date with priority
    /// - Parameters:
    ///   - date: The center date to prefetch around
    ///   - range: Number of days before and after to prefetch
    func prefetch(around date: Date, range: Int = 7) async {
        let calendar = Calendar.current
        let normalizedCenter = date.zero

        // Prioritize: center date first, then adjacent, then further out
        var offsets = [0]
        for i in 1...range {
            offsets.append(i)
            offsets.append(-i)
        }

        for offset in offsets {
            guard let targetDate = calendar.date(byAdding: .day, value: offset, to: normalizedCenter) else {
                continue
            }

            let normalizedDate = targetDate.zero

            // Fetch events if not cached or stale
            if eventCache[normalizedDate] == nil || eventCache[normalizedDate]?.isStale == true {
                let events = await fetchEvents(for: normalizedDate)
                eventCache[normalizedDate] = CacheEntry(data: events)
            }

            // Fetch reminders if not cached or stale
            if reminderCache[normalizedDate] == nil || reminderCache[normalizedDate]?.isStale == true {
                let reminders = await fetchReminders(for: normalizedDate)
                reminderCache[normalizedDate] = CacheEntry(data: reminders)
            }
        }

        cleanupCacheIfNeeded()
        logger.debug("Prefetched data for \(range * 2 + 1) days around \(date)")
    }

    /// Cleans up cache using LRU-style eviction
    private func cleanupCacheIfNeeded() {
        let today = Date.now.zero
        let calendar = Calendar.current
        let maxEntries = maxCacheDays

        // First pass: remove entries outside the date window
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

        // Second pass: if still over limit, remove least recently accessed
        if eventCache.count > maxEntries {
            let sortedByAccess = eventCache.sorted { $0.value.lastAccessedAt < $1.value.lastAccessedAt }
            let toRemove = sortedByAccess.prefix(eventCache.count - maxEntries)
            for (date, _) in toRemove {
                eventCache.removeValue(forKey: date)
            }
            logger.debug("LRU evicted \(toRemove.count) event cache entries")
        }

        if reminderCache.count > maxEntries {
            let sortedByAccess = reminderCache.sorted { $0.value.lastAccessedAt < $1.value.lastAccessedAt }
            let toRemove = sortedByAccess.prefix(reminderCache.count - maxEntries)
            for (date, _) in toRemove {
                reminderCache.removeValue(forKey: date)
            }
            logger.debug("LRU evicted \(toRemove.count) reminder cache entries")
        }
    }

    /// Returns cache statistics for debugging
    var cacheStats: (events: Int, reminders: Int, overdue: Bool, open: Bool) {
        (
            events: eventCache.count,
            reminders: reminderCache.count,
            overdue: overdueRemindersCache != nil,
            open: openRemindersCache != nil
        )
    }

    // MARK: - Change Handlers

    private func handleEventStoreChange() async {
        invalidateCache()
        send(.calendarsUpdated)
        logger.info("EventKit store changed, cache invalidated")
    }

    private func handleSettingsChange(_ change: AppSettings.SettingsChange) async {
        switch change {
        case .calendarSelection:
            // Calendar selection changed - notify observers but keep cache
            // (cache stores all events, filtering happens on read)
            send(.cacheInvalidated)
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

