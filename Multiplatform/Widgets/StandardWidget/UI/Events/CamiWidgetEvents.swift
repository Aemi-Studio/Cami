//
//  CamiWidgetEvents.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 14/11/23.
//

import SwiftUI

struct CamiWidgetEvents: View {
    @Environment(\.widgetContent)   private var content

    private var referenceDate: Date { content.date }
    private var configuration: StandardWidgetConfiguration { content.configuration }

    private var dates: [Date] {
        Set<Date>().union(content.items.keys).union(content.inlineEvents.keys).sorted()
    }

    var body: some View {
        VStack(spacing: 6) {
            ForEach(dates, id: \.timeIntervalSinceReferenceDate) { date in
                if relatesToOngoingEvents(for: date, relativeTo: referenceDate), !configuration.showOngoingEvents {
                    EmptyView()
                } else {
                    CamiWidgetEventsByDate(
                        date: date,
                        items: getEvents(for: date),
                        inlineEvents: getInlineEvents(for: date)
                    )
                }
            }
        }
    }

    private func relatesToOngoingEvents(for date: Date, relativeTo referenceDate: Date) -> Bool {
        date < referenceDate.zero
    }

    private func getEvents(for date: Date) -> [CalendarItem] {
        content.items[date] ?? []
    }

    private func getInlineEvents(for date: Date) -> [CalendarItem] {
        content.inlineEvents[date] ?? []
    }
}
