//
//  CamiWidgetEventsByDate.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 14/11/23.
//

import EventKit
import SwiftUI
import WidgetKit

struct CamiWidgetEventsByDate: View {
    @Environment(\.calendar)            private var calendar
    @Environment(\.widgetContent)       private var content
    @Environment(\.widgetFamily)        private var widgetFamily
    @Environment(\.customWidgetFamily)  private var customWidgetFamily

    private var configuration: StandardWidgetConfiguration { content.configuration }
    private var family: WidgetFamily { customWidgetFamily?.rawValue ?? widgetFamily }

    let date: Date
    private(set) var items: [CalendarItem] = []
    private(set) var inlineEvents: [CalendarItem] = []

    private var itemsThroughAllDayFiltering: [CalendarItem] {
        if configuration.allDayStyle == .hidden {
            items.filter { event in
                guard event.kind == .event else { return true }
                let isAllDay = event.isAllDay
                let isOngoingDisplayed = event.continuesPast(content.date) && configuration.showOngoingEvents
                return !isAllDay || isOngoingDisplayed
            }
        } else {
            items
        }
    }

    private var groupedItems: [[CalendarItem]] {
        if configuration.groupEvents {
            itemsThroughAllDayFiltering.grouped()
        } else {
            itemsThroughAllDayFiltering.map { [$0] }
        }
    }

    private var noEvents: Bool {
        inlineEvents.isEmpty && groupedItems.isEmpty
    }

    var areThereOngoingEvents: Bool {
        date < content.date.zero
    }

    var isUpToTomorrow: Bool {
        date.isToday || calendar.isDateInTomorrow(date)
    }

    @ViewBuilder private var inlineLeadingInformation: some View {
        if areThereOngoingEvents {
            Text(String(localized: "ongoingEvents.Title"))
        } else if isUpToTomorrow {
            Text(date.formattedUntilTomorrow)
                .accessibilityLabel(String(localized: "Events for \(date.formattedUntilTomorrow)"))
        } else {
            Group {
                Text(date.formattedAfterTomorrow.capitalized(with: .prefered)) +
                    Text(" • ") +
                    Text(date.relativeToNow)
            }
            .accessibilityLabel(String(
                localized: "Events for \(date.formattedAfterTomorrow), \(date.relativeToNow)"
            ))
        }
    }

    @ViewBuilder private var inlineTrailingInformation: some View {
        HStack {
            if family.isSmall {
                if inlineEvents.count >= 1 {
                    Text("\(inlineEvents.count)")
                        .foregroundStyle(.clear)
                        .fontWeight(.bold)
                        .padding(.horizontal, 2)
                        .background(Color.primary.opacity(0.25))
                        .overlay {
                            Text("\(inlineEvents.count)")
                            .fontWeight(.bold)
                            .foregroundStyle(Color.white)
                            .blendMode(.destinationOut)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 2))
                        .accessibilityLabel(
                            String(localized: "You have \(inlineEvents.count) all-day events.")
                        )
                        .compositingGroup()
                }
            } else {
                Text(inlineEvents[0].title)
                    .truncationMode(.tail)
                    .accessibilityLabel(
                        String(localized: "Today have \(inlineEvents[0].title) as first all-day events.")
                    )

                if inlineEvents.count > 1 {
                    Text("+\(inlineEvents.count - 1)")
                        .foregroundStyle(.clear)
                        .fontWeight(.bold)
                        .padding(.horizontal, 2)
                        .background(.white.opacity(0.25))
                        .overlay {
                            Text("+\(inlineEvents.count - 1)")
                                .foregroundStyle(Color.white)
                                .fontWeight(.bold)
                                .padding(.horizontal, 2)
                                .blendMode(.destinationOut)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 2))
                        .accessibilityLabel(
                            String(localized: "And you have also \(inlineEvents.count - 1) other all-day events.")
                        )
                        .compositingGroup()
                }
            }
        }
    }

    private var inlineInformation: some View {
        HStack {
            inlineLeadingInformation
            if !areThereOngoingEvents && inlineEvents.count > 0 {
                Spacer()
                inlineTrailingInformation
            }
        }
        .font(.caption2)
        .fontWeight(.medium)
        .foregroundStyle(Color.primary.tertiary)
        .padding(.horizontal, 1)
        .lineLimit(1)
    }

    var body: some View {
        if !noEvents {
            VStack(alignment: .leading, spacing: 2) {
                inlineInformation
                VStack(spacing: 2) {
                    if !configuration.showReminders || configuration.useUnifiedList {
                        unifiedList
                    } else {
                        remindersOnTopOfEvents
                    }
                }
            }
        }
    }

    @ViewBuilder private var unifiedList: some View {
        ForEach(Array(groupedItems.enumerated()), id: \.offset) { (_, element) in
            CamiWidgetEvent(groupedItem: element)
        }
    }

    @ViewBuilder private var remindersOnTopOfEvents: some View {
        let reminders = groupedItems.filter { $0.first?.kind == .some(.reminder) }
        let events = groupedItems.filter { $0.first?.kind == .some(.event) }
        ForEach(Array(reminders.enumerated()), id: \.offset) { (_, element) in
            CamiWidgetEvent(groupedItem: element)
        }
        ForEach(Array(events.enumerated()), id: \.offset) { (_, element) in
            CamiWidgetEvent(groupedItem: element)
        }
    }
}
