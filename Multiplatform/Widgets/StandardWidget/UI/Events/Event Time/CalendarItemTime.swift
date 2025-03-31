//
//  CalendarItemTime.swift
//  Cami
//
//  Created by Guillaume Coquard on 12/03/25.
//

import EventKit
import SwiftUI

struct CalendarItemTime: View {
    @Environment(\.widgetContent)
    private var content

    private var reference: Date { content.date }
    private var config: StandardWidgetConfiguration { content.configuration }

    let items: [CalendarItem]

    private var first: CalendarItem! { items.first }
    private var isAllDay: Bool { first.isAllDay }

    var body: some View {
        if !isAllDay || config.showOngoingEvents && first.continuesPast(reference) {
            VStack(alignment: .trailing, spacing: 1) {
                ForEach(items, id: \.id) { item in
                    timeComponent(for: item, relativeTo: reference)
                }
                .accessibilityLabel(
                    items.count > 1
                        ? "This event happens \(items.count) times in your day."
                        : ""
                )
            }
        }
    }

    @ViewBuilder
    private func timeComponent(for item: CalendarItem, relativeTo date: Date) -> some View {
        HStack(spacing: 2) {
            if item.boundStart < date {
                CalendarItemRemainingTime(
                    from: item.boundStart,
                    to: item.boundEnd,
                    accuracy: item.continuesPast(date)
                        ? [.day, .hour]
                        : [.day, .hour, .minute]
                )
            } else {
                CalendarItemStartTime(for: item)
            }
        }
        .monospacedDigit()
        .fontDesign(.rounded)
        .fontWeight(.semibold)
        .font(.caption)
    }
}
