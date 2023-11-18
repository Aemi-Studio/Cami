//
//  CamiWidgetEventsByDate.swift
//  Cami
//
//  Created by Guillaume Coquard on 14/11/23.
//

import SwiftUI
import EventKit

struct CamiWidgetEventsByDate: View {

    var date: Date
    var events: EventList = []
    var config: CamiWidgetConfiguration = .init()

    private var allDayEventStyle: AllDayEventStyle {
        config.allDayEventStyle
    }

    private var groupEvents: Bool {
        config.groupEvents
    }

    private var allDayEvents: EventList {
        if allDayEventStyle == .inline {
            return events.filter({ event in event.isAllDay })
        }
        return []
    }

    private var reducedEvents: [(EKEvent, EventList)] {
        if groupEvents {
            if allDayEventStyle != .event {
                return events.filter({ event in !(
                    event.isAllDay
                )}).reduced()
            }
            return events.reduced()
        } else {
            if allDayEventStyle != .event {
                return events.filter({ event in !(
                    event.isAllDay
                )}).map( { ($0,[$0]) } )
            }
            return events.map( { ($0,[$0]) } )
        }
    }

    var body: some View {
        if allDayEvents.isEmpty && reducedEvents.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(
                        (date >= Date.now.zero)
                        ? CamiUtils.relativeDate(date)
                        : "These days"
                    )
                    .fontDesign(.rounded)
                    .fontWeight(.medium)
                    .font(.system(size:12))
                    .foregroundStyle(.white.opacity(0.25))
                    .lineLimit(1)
                    Spacer()
                    if allDayEvents.count > 0 {
                        Group {
                            Text(allDayEvents[0].title)
                                .truncationMode(.tail)

                            if allDayEvents.count > 1 {
                                Text(" + \(allDayEvents.count - 1)")
                            }
                        }
                        .fontDesign(.rounded)
                        .fontWeight(.medium)
                        .font(.system(size:12))
                        .foregroundStyle(.white.opacity(0.25))
                        .lineLimit(1)
                    }
                }
                VStack(spacing: 2) {

                    ForEach(0..<reducedEvents.count, id: \.self) { index in

                        ViewThatFits {

                            CamiWidgetEvent(
                                event: reducedEvents[index]
                            )

                        }
                    }
                }
            }
        }
    }
}

//#Preview {
//    CamiWidgetEventsByDate()
//}
