//
//  AppState.swift
//  Cami
//
//  Created by Guillaume Coquard on 30/03/25.
//

import SwiftUI

@MainActor
@Observable
final class AppState: Loggable {
    /// The currently selected/viewed date
    private(set) var selectedDate: Date

    /// Current vertical scroll offset for the visible day (used for header effects)
    var currentScrollOffset: CGFloat = 0

    /// Whether the user is viewing today
    var isViewingToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    /// Cache for day contexts to avoid recreating them
    private var dayContextCache: [Date: SingleDayContext] = [:]

    /// Returns the day context for the selected date
    var dayContext: SingleDayContext {
        dayContext(for: selectedDate)
    }

    /// Returns or creates a cached day context for a specific date
    func dayContext(for date: Date) -> SingleDayContext {
        let normalizedDate = date.zero
        if let cached = dayContextCache[normalizedDate] {
            return cached
        }
        let context = SingleDayContext(for: normalizedDate)
        dayContextCache[normalizedDate] = context
        return context
    }

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

    /// Navigation state for the app
    let navigation = AppNavigation()
    let storage = AppStorageManager()

    init(date: Date = .now) {
        self.selectedDate = date.zero

        Task { @MainActor [weak self] in
            await self?.initialize()
        }
    }

    private func initialize() async {
        if !hasCompletedOnboarding {
            navigation.performComplexFlow(.onboarding)
        }
    }

    /// Clears old cached contexts to manage memory
    func cleanupOldContexts() {
        let today = Date.now.zero
        let calendar = Calendar.current
        dayContextCache = dayContextCache.filter { date, _ in
            guard let daysDiff = calendar.dateComponents([.day], from: date, to: today).day else {
                return false
            }
            return abs(daysDiff) <= 7
        }
    }
}
