//
//  RemainingTimeComponent.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 07/11/23.
//

import SwiftUI

struct RemainingTimeComponent: View {

    @Environment(CamiWidgetEntry.self)
    private var entry: CamiWidgetEntry

    private let startDate: Date
    private let endDate: Date
    private let accuracy: NSCalendar.Unit

    init(
        from startDate: Date,
        to endDate: Date,
        accuracy: NSCalendar.Unit = [.day, .hour, .minute]
    ) {
        self.startDate = startDate
        self.endDate = endDate
        self.accuracy = accuracy
    }

    var body: some View {

        HStack(spacing: 2) {
            if startDate < entry.date {
                let remainingTime: String = entry.date.remainingTime(
                    until: endDate,
                    accuracy: accuracy
                )
                Label("Remaining Time: \(remainingTime)", systemImage: "timer")
                    .labelStyle(.iconOnly)
                    .fontWeight(.bold)
                    .scaleEffect(0.8)
                    .accessibilityHint("This event ends in \(remainingTime).")

                Text(remainingTime)
                    .accessibilityHidden(true)

            } else {
                Text(startDate.formattedHour)
                    .accessibilityLabel("This event starts at \(startDate.formattedHour).")
            }
        }
        .monospacedDigit()
        .fontDesign(.rounded)
        .fontWeight(.semibold)
        .opacity(0.5)
    }

}
