//
//  LiveTimeView.swift
//  Cami
//
//  Created by Guillaume Coquard on 26/11/25.
//

import SwiftUI
import WidgetKit

// MARK: - Update Schedule

/// Defines how frequently a LiveTimeView should update its content.
enum LiveTimeUpdateSchedule: Sendable {
    /// Updates every second - use sparingly for countdowns
    case everySecond
    /// Updates every minute - suitable for most time displays
    case everyMinute
    /// Updates every hour - for day-level countdowns
    case everyHour
    /// Updates at specific dates
    case at([Date])
}

// MARK: - Live Time View

/// A reusable TimelineView wrapper that provides live time updates to its content.
///
/// Use this view to wrap any content that needs to display time-based information
/// that updates automatically, such as countdowns, remaining time, or elapsed time.
///
/// Example usage:
/// ```swift
/// LiveTimeView(schedule: .everyMinute) { currentDate in
///     Text(currentDate.remainingTime(until: eventEndDate))
/// }
/// ```
struct LiveTimeView<Content: View>: View {
    private let schedule: LiveTimeUpdateSchedule
    private let content: (Date) -> Content

    /// Creates a LiveTimeView with the specified update schedule.
    /// - Parameters:
    ///   - schedule: How frequently the view should update. Defaults to `.everyMinute`.
    ///   - content: A view builder that receives the current date and returns the content to display.
    init(
        schedule: LiveTimeUpdateSchedule = .everyMinute,
        @ViewBuilder content: @escaping (Date) -> Content
    ) {
        self.schedule = schedule
        self.content = content
    }

    var body: some View {
        switch schedule {
        case .everySecond:
            TimelineView(.periodic(from: .now, by: 1)) { context in
                content(context.date)
            }
        case .everyMinute:
            TimelineView(.periodic(from: .now, by: 60)) { context in
                content(context.date)
            }
        case .everyHour:
            TimelineView(.periodic(from: .now, by: 3600)) { context in
                content(context.date)
            }
        case .at(let dates):
            TimelineView(.explicit(dates)) { context in
                content(context.date)
            }
        }
    }
}

// MARK: - Convenience Initializers

extension LiveTimeView {
    /// Creates a LiveTimeView that updates every minute.
    /// - Parameter content: A view builder that receives the current date.
    static func everyMinute(
        @ViewBuilder content: @escaping (Date) -> Content
    ) -> LiveTimeView {
        LiveTimeView(schedule: .everyMinute, content: content)
    }

    /// Creates a LiveTimeView that updates every second.
    /// - Parameter content: A view builder that receives the current date.
    static func everySecond(
        @ViewBuilder content: @escaping (Date) -> Content
    ) -> LiveTimeView {
        LiveTimeView(schedule: .everySecond, content: content)
    }
}

// MARK: - Live Duration View

/// A specialized view for displaying duration/countdown information with automatic updates.
///
/// This view calculates and displays the remaining time between two dates,
/// automatically updating based on the specified schedule.
struct LiveDurationView: View {
    @Environment(\.widgetFamily) private var widgetFamily
    @Environment(\.customWidgetFamily) private var customWidgetFamily

    private var family: WidgetFamily {
        customWidgetFamily?.rawValue ?? widgetFamily
    }

    private let startDate: Date
    private let endDate: Date
    private let accuracy: NSCalendar.Unit
    private let schedule: LiveTimeUpdateSchedule
    private let showProgressCircle: Bool

    @ScaledMetric(relativeTo: .caption) private var circleSize: Double = 12

    /// Creates a LiveDurationView displaying remaining time.
    /// - Parameters:
    ///   - startDate: The start date of the duration (used for progress calculation).
    ///   - endDate: The end date (the target time).
    ///   - accuracy: The units to display in the formatted duration.
    ///   - schedule: How frequently to update. Defaults to `.everyMinute`.
    ///   - showProgressCircle: Whether to show a visual progress indicator.
    init(
        from startDate: Date,
        to endDate: Date,
        accuracy: NSCalendar.Unit = [.day, .hour, .minute],
        schedule: LiveTimeUpdateSchedule = .everyMinute,
        showProgressCircle: Bool = true
    ) {
        self.startDate = startDate
        self.endDate = endDate
        self.accuracy = accuracy
        self.schedule = schedule
        self.showProgressCircle = showProgressCircle
    }

    var body: some View {
        LiveTimeView(schedule: schedule) { currentDate in
            durationContent(at: currentDate)
        }
    }

    @ViewBuilder
    private func durationContent(at currentDate: Date) -> some View {
        let remainingTime = currentDate.remainingTime(until: endDate, accuracy: accuracy)
        let progress = 1 - currentDate.distance(to: endDate) / startDate.distance(to: endDate)

        HStack(spacing: 4) {
            if !family.isSmall {
                Text(remainingTime)
                    .accessibilityHidden(true)
                    .opacity(0.5)
            }

            if showProgressCircle {
                Label {
                    Text(String(localized: "Remaining Time: \(remainingTime)"))
                } icon: {
                    ProgressCircle(
                        progress: progress,
                        lineWidthRatio: 0.2
                    )
                    .frame(height: circleSize)
                }
                .labelStyle(.iconOnly)
                .accessibilityHint(String(localized: "This event ends in \(remainingTime)."))
            }
        }
    }
}

// MARK: - Live Countdown Text

/// A simple text view that displays a countdown, updating automatically.
struct LiveCountdownText: View {
    private let targetDate: Date
    private let accuracy: NSCalendar.Unit
    private let schedule: LiveTimeUpdateSchedule

    /// Creates a countdown text that updates automatically.
    /// - Parameters:
    ///   - targetDate: The date to count down to.
    ///   - accuracy: The units to display.
    ///   - schedule: How frequently to update.
    init(
        to targetDate: Date,
        accuracy: NSCalendar.Unit = [.day, .hour, .minute],
        schedule: LiveTimeUpdateSchedule = .everyMinute
    ) {
        self.targetDate = targetDate
        self.accuracy = accuracy
        self.schedule = schedule
    }

    var body: some View {
        LiveTimeView(schedule: schedule) { currentDate in
            Text(currentDate.remainingTime(until: targetDate, accuracy: accuracy))
        }
    }
}
