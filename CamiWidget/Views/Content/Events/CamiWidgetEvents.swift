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
        
        let dates: Dates = Array(entry.events.keys).sorted()

        VStack(spacing: 6) {

            ForEach(0..<dates.count, id: \.self) { dateIndex in

                ViewThatFits {

                    let date: Date = dates[dateIndex]
                    let _events: Events = entry.events[date] ?? []

                    CamiWidgetEventsByDate(
                        date: date,
                        events: _events.sortedEventByAscendingDate()
                    )

                }
                
            }

        }

    }
}

#Preview {
    CamiWidgetEvents()
}
