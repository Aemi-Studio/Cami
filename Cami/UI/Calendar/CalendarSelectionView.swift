//
//  CalendarSelectionView.swift
//  Cami
//
//  Created by Guillaume Coquard on 21/11/23.
//

import EventKit
import SwiftUI

struct CalendarSelectionView: View {
    @Environment(\.views) private var views: UIContext!
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
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(calendarsAsDict.keys.sorted(), id: \.self) { source in
                    if let calendars = calendarsAsDict[source] {
                        Section {
                            ForEach(calendars, id: \.calendarIdentifier) { calendar in
                                CalendarToggleButton(calendar: calendar)
                            }
                        } header: {
                            Text(source)
                                .font(.subheadline)
                                .foregroundStyle(.foreground.secondary)
                        }
                    }
                }
            }
        }
        .safeAreaPadding(.top)
        .padding()
    }
}

#Preview {
    CalendarSelectionView()
}
