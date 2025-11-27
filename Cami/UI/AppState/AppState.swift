//
//  AppState.swift
//  Cami
//
//  Created by Guillaume Coquard on 30/03/25.
//

import SwiftUI

/// Application state coordinator.
///
/// AppState has been simplified to coordinate between the new architecture components:
/// - DayStore: manages selected date and calendar data
/// - CalendarStore: manages calendar caching
/// - AppSettings: manages user preferences
///
/// It retains:
/// - Navigation state
/// - View-specific state (scroll offset)
/// - Legacy compatibility layer during migration
@MainActor
@Observable
final class AppState: Loggable {
    /// The currently selected/viewed date (synced with DayStore)
    private(set) var selectedDate: Date

    /// Current vertical scroll offset for the visible day (used for header effects)
    var currentScrollOffset: CGFloat = 0

    /// Whether the user is viewing today
    var isViewingToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    /// Navigation state for the app
    let navigation = AppNavigation()
    let storage = AppStorageManager()

    let settings = AppSettings.shared

    init(date: Date = .now) {
        self.selectedDate = date.zero

        Task { @MainActor [weak self] in
            await self?.initialize()
        }
    }

    private func initialize() async {
        // Use legacy storage for synchronous access during initialization
        if !hasCompletedOnboarding {
            navigation.performComplexFlow(.onboarding)
        }
    }

    // MARK: - Navigation

    /// Navigates to a specific date
    func navigateTo(date: Date) {
        selectedDate = date.zero
    }

    /// Navigates to today
    func navigateToToday() {
        selectedDate = Date.now.zero
    }

    /// Navigates to the next day
    func navigateToNextDay() {
        if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
            selectedDate = nextDay.zero
        }
    }

    /// Navigates to the previous day
    func navigateToPreviousDay() {
        if let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            selectedDate = previousDay.zero
        }
    }

    // MARK: - Legacy Compatibility

    /// Returns the day context for the selected date
    /// - Note: SingleDayContext now uses CalendarStore internally for caching
    var dayContext: SingleDayContext {
        SingleDayContext(for: selectedDate)
    }

    /// Returns or creates a day context for a specific date
    /// - Note: Caching is now handled by CalendarStore, contexts are lightweight
    func dayContext(for date: Date) -> SingleDayContext {
        SingleDayContext(for: date.zero)
    }
}
