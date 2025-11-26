//
//  OngoingEventAttributes.swift
//  Cami
//
//  Created by Guillaume Coquard on 26/11/25.
//

import ActivityKit
import Foundation

/// Attributes for an ongoing calendar event Live Activity.
///
/// This struct defines both the static attributes (event details that don't change)
/// and the dynamic content state (remaining time updates) for the Live Activity.
struct OngoingEventAttributes: ActivityAttributes {
    /// Dynamic state that updates throughout the activity's lifecycle.
    struct ContentState: Codable, Hashable, Sendable {
        /// The current progress through the event (0.0 to 1.0)
        let progress: Double

        /// Whether the event has ended
        let hasEnded: Bool

        /// Creates an updated content state based on the current time.
        static func current(startDate: Date, endDate: Date) -> ContentState {
            let now = Date.now
            let totalDuration = endDate.timeIntervalSince(startDate)
            let elapsed = now.timeIntervalSince(startDate)
            let progress = min(max(elapsed / totalDuration, 0), 1)
            let hasEnded = now >= endDate

            return ContentState(progress: progress, hasEnded: hasEnded)
        }
    }

    /// The unique identifier of the calendar event
    let eventIdentifier: String

    /// The title of the event
    let title: String

    /// The location of the event (if any)
    let location: String?

    /// When the event started
    let startDate: Date

    /// When the event ends
    let endDate: Date

    /// The calendar color as RGB components (for reconstruction in widget)
    let colorRed: Double
    let colorGreen: Double
    let colorBlue: Double

    /// Whether this is an all-day event
    let isAllDay: Bool
}

// MARK: - Convenience Extensions

extension OngoingEventAttributes {
    /// Creates attributes from event details.
    init(
        eventIdentifier: String,
        title: String,
        location: String?,
        startDate: Date,
        endDate: Date,
        color: (red: Double, green: Double, blue: Double),
        isAllDay: Bool
    ) {
        self.eventIdentifier = eventIdentifier
        self.title = title
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        self.colorRed = color.red
        self.colorGreen = color.green
        self.colorBlue = color.blue
        self.isAllDay = isAllDay
    }

    /// The event duration
    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }

    /// Returns the remaining time from a given date
    func remainingTime(from date: Date = .now) -> TimeInterval {
        max(endDate.timeIntervalSince(date), 0)
    }
}
