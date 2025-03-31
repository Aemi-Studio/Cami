//
//  CalendarItemRemainingTime.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 07/11/23.
//

import SwiftUI
import WidgetKit

struct CalendarItemRemainingTime: View {
    @Environment(\.widgetContent) private var content
    @Environment(\.widgetFamily) private var widgetFamily
    @Environment(\.customWidgetFamily) private var customWidgetFamily
    private var family: WidgetFamily { customWidgetFamily?.rawValue ?? widgetFamily }

    @ScaledMetric(relativeTo: .caption) private var circleSize: Double = 12

    private let beginDate: Date
    private let endDate: Date
    private let accuracy: NSCalendar.Unit

    private var remainingTime: String {
        content.date.remainingTime(until: endDate, accuracy: accuracy)
    }

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
        HStack(spacing: 4) {
            if !family.isSmall {
                Text(remainingTime)
                    .accessibilityHidden(true)
                    .opacity(0.5)
            }

            Label {
                Text(String(localized: "Remaining Time: \(remainingTime)"))
            } icon: {
                ProgressCircle(
                    progress: 1 - Date.now.distance(to: endDate) / beginDate.distance(to: endDate),
                    lineWidthRatio: 0.2
                )
                .frame(height: circleSize)
            }
            .labelStyle(.iconOnly)
            .accessibilityHint(String(localized: "This event ends in \(remainingTime)."))
        }
    }
}
