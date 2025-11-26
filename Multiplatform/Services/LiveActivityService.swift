//
//  LiveActivityService.swift
//  Cami
//
//  Created by Guillaume Coquard on 26/11/25.
//

import ActivityKit
import EventKit
import Foundation
import OSLog

/// Service responsible for managing Live Activities for ongoing calendar events.
///
/// This actor monitors the user's calendar and automatically starts, updates,
/// and ends Live Activities based on event timing.
actor LiveActivityService {
    static let shared = LiveActivityService()

    private let logger = Logger(subsystem: "dev.music.cami", category: "LiveActivityService")

    /// Currently active Live Activities keyed by event identifier
    private var activeActivities: [String: Activity<OngoingEventAttributes>] = [:]

    /// Task for periodic monitoring
    private var monitoringTask: Task<Void, Never>?

    /// Whether the service is currently monitoring
    private var isMonitoring = false

    private init() {}

    // MARK: - Public API

    /// Starts monitoring for ongoing events and managing their Live Activities.
    func startMonitoring() {
        guard !isMonitoring else {
            logger.debug("Already monitoring, skipping start")
            return
        }

        isMonitoring = true
        logger.info("Starting Live Activity monitoring")

        monitoringTask = Task { [weak self] in
            // Check immediately
            await self?.checkOngoingEvents()

            // Then check every minute
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(60))
                guard !Task.isCancelled else { break }
                await self?.checkOngoingEvents()
            }
        }
    }

    /// Stops monitoring and ends all active Live Activities.
    func stopMonitoring() {
        logger.info("Stopping Live Activity monitoring")
        isMonitoring = false
        monitoringTask?.cancel()
        monitoringTask = nil

        Task {
            await endAllActivities()
        }
    }

    /// Manually starts a Live Activity for a specific event.
    @discardableResult
    func startActivity(for event: EKEvent) async -> Activity<OngoingEventAttributes>? {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            logger.warning("Live Activities are not enabled")
            return nil
        }

        guard !event.isAllDay else {
            logger.debug("Skipping all-day event: \(event.title ?? "Untitled")")
            return nil
        }

        let identifier = event.eventIdentifier ?? UUID().uuidString

        // Don't create duplicate activities
        if let existing = activeActivities[identifier] {
            logger.debug("Activity already exists for event: \(event.title ?? "Untitled")")
            return existing
        }

        let calendarColor = event.calendar?.cgColor?.components ?? [0.5, 0.5, 0.5, 1.0]
        let attributes = OngoingEventAttributes(
            eventIdentifier: identifier,
            title: event.title ?? String(localized: "liveActivity.untitledEvent"),
            location: event.location,
            startDate: event.startDate,
            endDate: event.endDate,
            color: (
                red: Double(calendarColor[0]),
                green: Double(calendarColor[1]),
                blue: Double(calendarColor[2])
            ),
            isAllDay: event.isAllDay
        )

        let initialState = OngoingEventAttributes.ContentState.current(
            startDate: event.startDate,
            endDate: event.endDate
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: event.endDate),
                pushType: nil
            )

            activeActivities[identifier] = activity
            logger.info("Started Live Activity for: \(event.title ?? "Untitled")")

            // Schedule activity to end when event ends
            scheduleActivityEnd(for: identifier, at: event.endDate)

            return activity
        } catch {
            logger.error("Failed to start Live Activity: \(error.localizedDescription)")
            return nil
        }
    }

    /// Updates the state of an existing Live Activity.
    func updateActivity(for eventIdentifier: String, startDate: Date, endDate: Date) async {
        guard let activity = activeActivities[eventIdentifier] else {
            return
        }

        let newState = OngoingEventAttributes.ContentState.current(
            startDate: startDate,
            endDate: endDate
        )

        await activity.update(.init(state: newState, staleDate: endDate))
        logger.debug("Updated Live Activity for event: \(eventIdentifier)")
    }

    /// Ends a Live Activity for a specific event.
    func endActivity(for eventIdentifier: String) async {
        guard let activity = activeActivities[eventIdentifier] else {
            return
        }

        let finalState = OngoingEventAttributes.ContentState(progress: 1.0, hasEnded: true)

        await activity.end(
            .init(state: finalState, staleDate: nil),
            dismissalPolicy: .immediate
        )

        activeActivities.removeValue(forKey: eventIdentifier)
        logger.info("Ended Live Activity for event: \(eventIdentifier)")
    }

    // MARK: - Private Methods

    /// Checks for ongoing events and manages their Live Activities.
    private func checkOngoingEvents() async {
        let now = Date.now

        // Get events happening right now (must hop to MainActor for DataContext)
        let ongoingEvents = await MainActor.run {
            DataContext.shared.events(during: 1, relativeTo: now).filter { event in
                guard let startDate = event.startDate,
                      let endDate = event.endDate
                else {
                    return false
                }
                return !event.isAllDay && startDate <= now && endDate > now
            }
        }

        // Start activities for ongoing events that don't have one
        for event in ongoingEvents {
            guard let identifier = event.eventIdentifier else { continue }

            if activeActivities[identifier] == nil {
                await startActivity(for: event)
            } else {
                // Update existing activity
                await updateActivity(
                    for: identifier,
                    startDate: event.startDate,
                    endDate: event.endDate
                )
            }
        }

        // End activities for events that are no longer ongoing
        let ongoingIdentifiers = Set(ongoingEvents.compactMap(\.eventIdentifier))
        let activeIdentifiers = Set(activeActivities.keys)
        let endedIdentifiers = activeIdentifiers.subtracting(ongoingIdentifiers)

        for identifier in endedIdentifiers {
            await endActivity(for: identifier)
        }
    }

    /// Schedules the activity to end when the event ends.
    private func scheduleActivityEnd(for identifier: String, at endDate: Date) {
        let timeUntilEnd = endDate.timeIntervalSinceNow

        guard timeUntilEnd > 0 else {
            Task {
                await endActivity(for: identifier)
            }
            return
        }

        Task { [weak self] in
            try? await Task.sleep(for: .seconds(timeUntilEnd))
            await self?.endActivity(for: identifier)
        }
    }

    /// Ends all active Live Activities.
    private func endAllActivities() async {
        for identifier in activeActivities.keys {
            await endActivity(for: identifier)
        }
    }
}

// MARK: - Convenience Extension for EKEvent

extension EKEvent {
    /// Starts a Live Activity for this event if it's currently ongoing.
    func startLiveActivityIfOngoing() async {
        let now = Date.now
        guard let startDate, let endDate,
              !isAllDay,
              startDate <= now,
              endDate > now
        else {
            return
        }

        await LiveActivityService.shared.startActivity(for: self)
    }
}
