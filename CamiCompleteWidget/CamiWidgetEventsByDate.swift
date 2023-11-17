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
    var allDayEventStyle: AllDayEventStyle = .event

    private var allDayEvents: EventList {
        if allDayEventStyle == .inline {
            return events.filter({ event in event.isAllDay })
        }
        return []
    }

    private var reducedEvents: [(EKEvent, EventList)] {
        if allDayEventStyle != .event {
            return events.filter({ event in !(
                event.isAllDay
            )}).reduced()
        }
        return events.reduced()
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 2) {
            if allDayEvents.isEmpty && reducedEvents.isEmpty {
                EmptyView()
            } else {
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
