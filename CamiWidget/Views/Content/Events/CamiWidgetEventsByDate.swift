//
//  CamiWidgetEventsByDate.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 14/11/23.
//

import SwiftUI
import EventKit
import WidgetKit

struct CamiWidgetEventsByDate: View {

    @Environment(CamiWidgetEntry.self)
    private var entry: CamiWidgetEntry

    @Environment(\.widgetFamily)
    private var widgetFamily: WidgetFamily

    var date: Date
    var events: Events = []
    var inlineEvents: Events = []

    private var reducedEvents: [(EKEvent, Events)] {
        if entry.config.groupEvents {
            if entry.config.allDayStyle == .hidden {
                return events.filter({ event in !(
                    event.isAllDay && !(event.spansMore(than: entry.date) && entry.config.displayOngoingEvents)
                )}).reduced()
            }
            return events.reduced()
        } else {
            if entry.config.allDayStyle == .hidden {
                return events.filter({ event in !(
                    event.isAllDay && !(event.spansMore(than: entry.date) && entry.config.displayOngoingEvents)
                )}).map({ ($0, [$0]) })
            }
            return events.map({ ($0, [$0]) })
        }
    }

    var ongoingEvents: Bool {
        date < entry.date.zero
    }

    var isUpToTomorrow: Bool {
        date.isToday || Calendar.autoupdatingCurrent.isDateInTomorrow(date)
    }

    var body: some View {

        if inlineEvents.isEmpty && reducedEvents.isEmpty {

            EmptyView()

        } else {

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Group {
                        if ongoingEvents {
                            Text("Ongoing Events")
                        } else if isUpToTomorrow {
                            Text(date.formattedUntilTomorrow)
                                .accessibilityLabel(
                                    "Events for \(date.formattedUntilTomorrow)"
                                )
                        } else {
                            Group {
                                Text(date.formattedAfterTomorrow) +
                                    Text(" • ") +
                                    Text(date.relativeToNow)
                            }
                            .accessibilityLabel(
                                "Events for \(date.formattedAfterTomorrow), \(date.relativeToNow)"
                            )
                        }
                    }
                    .fontDesign(.rounded)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.25))
                    .lineLimit(1)
                    Spacer()
                    if !ongoingEvents && inlineEvents.count > 0 {
                        HStack {
                            if widgetFamily.isSmall {
                                if inlineEvents.count >= 1 {
                                    Text("\(inlineEvents.count)")
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color(white: 0.1))
                                        .padding(.horizontal, 2)
                                        .background(.white.opacity(0.25))
                                        .clipShape(RoundedRectangle(cornerRadius: 2))
                                        .accessibilityLabel(
                                            "You have \(inlineEvents.count) all-day events."
                                        )
                                }
                            } else {
                                Text(inlineEvents[0].title)
                                    .truncationMode(.tail)
                                    .accessibilityLabel(
                                        "Today have \(inlineEvents[0].title) as first all-day events."
                                    )

                                if inlineEvents.count > 1 {
                                    Text("+\(inlineEvents.count - 1)")
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color(white: 0.1))
                                        .padding(.horizontal, 2)
                                        .background(.white.opacity(0.25))
                                        .clipShape(RoundedRectangle(cornerRadius: 2))
                                        .accessibilityLabel(
                                            "And you have also \(inlineEvents.count - 1) other all-day events."
                                        )
                                }
                            }
                        }
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.25))
                        .lineLimit(1)
                    }
                }
                .fontDesign(.rounded)
                .font(.caption2)
                .padding(.horizontal, 1)

                VStack(spacing: 2) {
                    ForEach(0..<reducedEvents.count, id: \.self) { index in
                        ViewThatFits {
                            CamiWidgetEvent( event: reducedEvents[index] )
                        }
                    }
                }
            }
        }
    }
}
