//
//  CalendarSelectionView.swift
//  Cami
//
//  Created by Guillaume Coquard on 21/11/23.
//

import EventKit
import SwiftUI

struct CalendarSelectionView: View {
    @Environment(\.data) private var data

    let kind: CalendarItem.Kind

    private var calendars: [EKCalendar] {
        switch kind {
        case .event:
            return data?.calendars ?? []
        case .reminder:
            return data?.taskLists ?? []
        case .streak:
            return data?.calendars ?? []
        }
    }

    private var calendarsBySource: [String: [EKCalendar]] {
        Dictionary(grouping: calendars) { $0.source?.title ?? "Unknown" }
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(calendarsBySource.keys.sorted(), id: \.self) { source in
                    if let sourceCalendars = calendarsBySource[source] {
                        CustomSection {
                            Text(source)
                        } content: {
                            ForEach(sourceCalendars, id: \.calendarIdentifier) { calendar in
                                CalendarToggleButton(calendar: calendar)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(kind.listPluralDescription)
        .navigationBarTitleDisplayMode(.automatic)
    }
}

#Preview {
    CalendarSelectionView(kind: .event)
}
