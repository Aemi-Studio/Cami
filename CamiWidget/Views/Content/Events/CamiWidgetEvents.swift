//
//  CamiWidgetEvents.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 14/11/23.
//

import SwiftUI

struct CamiWidgetEvents: View {

    @EnvironmentObject var entry: CamiWidgetEntry

    var body: some View {

        var dates: Dates {
            Set<Date>().union(entry.events.keys).union(entry.inlineEvents.keys).sorted()
        }

        VStack(spacing: 6) {
            ForEach(0..<dates.count, id: \.self) { dateIndex in
                let date: Date = dates[dateIndex]
                if date < entry.date.zero && !entry.config.displayOngoingEvents {
                    EmptyView()
                } else {
                    ViewThatFits {
                        let eventsForDate: Events = entry.events[date] ?? []
                        let inlineEventsForDate: Events = entry.inlineEvents[date] ?? []
                        CamiWidgetEventsByDate(
                            date: date,
                            events: eventsForDate,
                            inlineEvents: inlineEventsForDate
                        )
                    }
                }
            }

        }

    }
}

#Preview {
    CamiWidgetEvents()
}
