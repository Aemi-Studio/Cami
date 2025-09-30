//
//  CalendarSelectionView.swift
//  Cami
//
//  Created by Guillaume Coquard on 21/11/23.
//

import EventKit
import SwiftUI

struct CalendarSelectionView: View {
    @Environment(\.appState) private var state
    @Environment(\.data) private var data

    private var calendars: [EKCalendar] {
        data?.calendars ?? []
    }

    private var calendarsAsDict: [String: [EKCalendar]] {
        calendars.reduce(into: [String: [EKCalendar]]()) { result, calendar in
            let sourceTitle: String = calendar.source.title
            if let oldValue = result[sourceTitle] {
                var newValue = oldValue
                newValue.append(calendar)
                result.updateValue(newValue, forKey: sourceTitle)
            } else {
                result[sourceTitle] = [calendar]
            }
        }
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(calendarsAsDict.keys.sorted(), id: \.self) { source in
                    if let calendars = calendarsAsDict[source] {
                        CustomSection {
                            Text(source)
                        } content: {
                            ForEach(calendars, id: \.calendarIdentifier) { calendar in
                                CalendarToggleButton(calendar: calendar)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(CalendarItem.Kind.event.listPluralDescription)
        .navigationBarTitleDisplayMode(.automatic)
    }
}

#Preview {
    CalendarSelectionView()
}
