//
//  CalendarItemRemainingTime.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 07/11/23.
//

import SwiftUI
import WidgetKit

/// Displays the remaining time for an ongoing calendar event with a progress indicator.
///
/// This view uses `LiveDurationView` internally to provide automatic time updates
/// in widget contexts, showing how much time remains until the event ends.
struct CalendarItemRemainingTime: View {
    private let beginDate: Date
    private let endDate: Date
    private let accuracy: NSCalendar.Unit

    /// Creates a remaining time view for an event.
    /// - Parameters:
    ///   - beginDate: When the event started (used for progress calculation).
    ///   - endDate: When the event ends.
    ///   - accuracy: The time units to display. Defaults to day, hour, and minute.
    init(
        from beginDate: Date,
        to endDate: Date,
        accuracy: NSCalendar.Unit = [.day, .hour, .minute]
    ) {
        self.beginDate = beginDate
        self.endDate = endDate
        self.accuracy = accuracy
    }

    var body: some View {
        LiveDurationView(
            from: beginDate,
            to: endDate,
            accuracy: accuracy,
            schedule: scheduleForAccuracy,
            showProgressCircle: true
        )
    }

    /// Determines the appropriate update schedule based on accuracy requirements.
    private var scheduleForAccuracy: LiveTimeUpdateSchedule {
        if accuracy.contains(.second) {
            return .everySecond
        } else if accuracy.contains(.minute) {
            return .everyMinute
        } else {
            return .everyHour
        }
    }
}
