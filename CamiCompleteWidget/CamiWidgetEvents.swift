//
//  CamiWidgetEvents.swift
//  CamiWidgetExtension
//
//  Created by Guillaume Coquard on 14/11/23.
//

import SwiftUI
import EventKit

struct CamiWidgetEvents: View {
    
    var events: EventDict = [:]
    var allDayEventStyle: AllDayEventStyle = .event

    var body: some View {

        let dates = Array(events.keys).sorted()

        LazyVStack(spacing: 6) {

            ForEach(0..<dates.count, id: \.self) { dateIndex in

                ViewThatFits {

                    let date : Date = dates[dateIndex]
                    let eventList: EventList = (
                        events[date] ?? []
                    ).sortedEventByAscendingDate()

                    CamiWidgetEventsByDate(
                        date: date,
                        events: eventList,
                        allDayEventStyle: allDayEventStyle
                    )
                }
            }
        }
    }
}

#Preview {
    CamiWidgetEvents()
}
