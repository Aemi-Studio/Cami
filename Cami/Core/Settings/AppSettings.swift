//
//  AppSettings.swift
//  Cami
//
//  Created by Guillaume Coquard on 26/11/25.
//

import Foundation
import OSLog

/// Centralized, thread-safe storage for all user preferences.
///
/// AppSettings is the single source of truth for:
/// - Calendar selection (which calendars are visible)
/// - View preferences (show events, show reminders)
/// - Onboarding state
/// - App-wide settings
actor AppSettings {
    static let shared = AppSettings()

    private let logger = Logger(subsystem: "dev.music.cami", category: "AppSettings")
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    /// Continuations for settings change streams
    private var continuations: [UUID: AsyncStream<SettingsChange>.Continuation] = [:]

    /// Creates an AsyncStream that emits settings changes
    func settingsChanges() -> AsyncStream<SettingsChange> {
        let (stream, continuation) = AsyncStream.makeStream(of: SettingsChange.self)
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
    private func send(_ change: SettingsChange) {
        for continuation in continuations.values {
            continuation.yield(change)
        }
    }

    // MARK: - Settings Change Types

    enum SettingsChange: Sendable {
        case calendarSelection(Set<String>)
        case showEvents(Bool)
        case showReminders(Bool)
        case onboardingCompleted
        case onboardingStepCompleted(OnboardingStep)
    }

    // MARK: - Storage Keys

    private enum Keys: String {
        case selectedCalendarIDs = "cami.settings.selectedCalendarIDs"
        case showEvents = "cami.settings.showEvents"
        case showReminders = "cami.settings.showReminders"
        case hasCompletedOnboarding = "hasCompletedInitialOnboarding"
        case completedOnboardingSteps = "completedOnboardingSteps"
        case accessWorkInProgressFeatures = "accessWorkInProgressFeatures"
        case openInCami = "openInCami"
    }

    // MARK: - Cached State

    private var _selectedCalendarIDs: Set<String>?
    private var _showEvents: Bool?
    private var _showReminders: Bool?
    private var _hasCompletedOnboarding: Bool?
    private var _completedOnboardingSteps: Set<OnboardingStep>?

    // MARK: - Initialization

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Calendar Selection

    /// The set of calendar identifiers that are currently enabled/visible
    var selectedCalendarIDs: Set<String> {
        get {
            if let cached = _selectedCalendarIDs {
                return cached
            }
            let loaded = loadSet(String.self, forKey: Keys.selectedCalendarIDs.rawValue)
            _selectedCalendarIDs = loaded
            return loaded
        }
    }

    /// Checks if a specific calendar is selected
    func isCalendarSelected(_ calendarID: String) -> Bool {
        selectedCalendarIDs.contains(calendarID)
    }

    /// Toggles the selection state of a calendar
    func toggleCalendar(_ calendarID: String) {
        var current = selectedCalendarIDs
        if current.contains(calendarID) {
            current.remove(calendarID)
        } else {
            current.insert(calendarID)
        }
        setSelectedCalendarIDs(current)
    }

    /// Sets a calendar's selection state
    func setCalendarSelected(_ calendarID: String, selected: Bool) {
        var current = selectedCalendarIDs
        if selected {
            current.insert(calendarID)
        } else {
            current.remove(calendarID)
        }
        setSelectedCalendarIDs(current)
    }

    /// Sets the complete set of selected calendar IDs
    func setSelectedCalendarIDs(_ ids: Set<String>) {
        _selectedCalendarIDs = ids
        saveSet(ids, forKey: Keys.selectedCalendarIDs.rawValue)
        send(.calendarSelection(ids))
        logger.debug("Calendar selection updated: \(ids.count) calendars selected")
    }

    /// Initializes calendar selection with all available calendars if not yet set
    func initializeCalendarSelectionIfNeeded(with calendarIDs: [String]) {
        if _selectedCalendarIDs == nil && defaults.object(forKey: Keys.selectedCalendarIDs.rawValue) == nil {
            let allIDs = Set(calendarIDs)
            setSelectedCalendarIDs(allIDs)
            logger.info("Initialized calendar selection with \(allIDs.count) calendars")
        }
    }

    // MARK: - Visibility Toggles

    /// Whether events should be displayed
    var showEvents: Bool {
        get {
            if let cached = _showEvents {
                return cached
            }
            // Default to true if never set
            let loaded = defaults.object(forKey: Keys.showEvents.rawValue) as? Bool ?? true
            _showEvents = loaded
            return loaded
        }
    }

    /// Sets whether events should be displayed
    func setShowEvents(_ show: Bool) {
        _showEvents = show
        defaults.set(show, forKey: Keys.showEvents.rawValue)
        send(.showEvents(show))
        logger.debug("Show events: \(show)")
    }

    /// Whether reminders should be displayed
    var showReminders: Bool {
        get {
            if let cached = _showReminders {
                return cached
            }
            // Default to true if never set
            let loaded = defaults.object(forKey: Keys.showReminders.rawValue) as? Bool ?? true
            _showReminders = loaded
            return loaded
        }
    }

    /// Sets whether reminders should be displayed
    func setShowReminders(_ show: Bool) {
        _showReminders = show
        defaults.set(show, forKey: Keys.showReminders.rawValue)
        send(.showReminders(show))
        logger.debug("Show reminders: \(show)")
    }

    // MARK: - Onboarding

    /// Whether the user has completed the initial onboarding
    var hasCompletedOnboarding: Bool {
        get {
            if let cached = _hasCompletedOnboarding {
                return cached
            }
            let loaded = defaults.bool(forKey: Keys.hasCompletedOnboarding.rawValue)
            _hasCompletedOnboarding = loaded
            return loaded
        }
    }

    /// Marks onboarding as completed
    func completeOnboarding() {
        _hasCompletedOnboarding = true
        defaults.set(true, forKey: Keys.hasCompletedOnboarding.rawValue)
        send(.onboardingCompleted)
        logger.info("Onboarding completed")
    }

    /// The set of completed onboarding steps
    var completedOnboardingSteps: Set<OnboardingStep> {
        get {
            if let cached = _completedOnboardingSteps {
                return cached
            }
            let loaded = loadSet(OnboardingStep.self, forKey: Keys.completedOnboardingSteps.rawValue)
            _completedOnboardingSteps = loaded
            return loaded
        }
    }

    /// Marks a specific onboarding step as completed
    func completeOnboardingStep(_ step: OnboardingStep) {
        var current = completedOnboardingSteps
        current.insert(step)
        _completedOnboardingSteps = current
        saveSet(current, forKey: Keys.completedOnboardingSteps.rawValue)
        send(.onboardingStepCompleted(step))
        logger.debug("Completed onboarding step: \(step.rawValue)")
    }

    /// Checks if a specific onboarding step has been completed
    func hasCompletedOnboardingStep(_ step: OnboardingStep) -> Bool {
        completedOnboardingSteps.contains(step)
    }

    // MARK: - App Preferences

    /// Whether work-in-progress features are accessible
    var accessWorkInProgressFeatures: Bool {
        defaults.bool(forKey: Keys.accessWorkInProgressFeatures.rawValue)
    }

    /// Sets whether work-in-progress features are accessible
    func setAccessWorkInProgressFeatures(_ access: Bool) {
        defaults.set(access, forKey: Keys.accessWorkInProgressFeatures.rawValue)
    }

    /// Whether to open links in Cami
    var openInCami: Bool {
        defaults.bool(forKey: Keys.openInCami.rawValue)
    }

    /// Sets whether to open links in Cami
    func setOpenInCami(_ openInCami: Bool) {
        defaults.set(openInCami, forKey: Keys.openInCami.rawValue)
    }

    // MARK: - Private Helpers

    private func loadSet<T: Codable & Hashable>(_ type: T.Type, forKey key: String) -> Set<T> {
        guard let data = defaults.data(forKey: key) else {
            return []
        }
        do {
            return try decoder.decode(Set<T>.self, from: data)
        } catch {
            logger.error("Failed to decode Set<\(String(describing: T.self))>: \(error.localizedDescription)")
            return []
        }
    }

    private func saveSet<T: Codable & Hashable>(_ set: Set<T>, forKey key: String) {
        do {
            let data = try encoder.encode(set)
            defaults.set(data, forKey: key)
        } catch {
            logger.error("Failed to encode Set<\(String(describing: T.self))>: \(error.localizedDescription)")
        }
    }
}

// MARK: - OnboardingStep Codable

/// Extends OnboardingStep with Codable conformance for persistence
extension OnboardingStep: Codable {}
