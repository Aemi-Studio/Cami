//
//  SingleDayView.swift
//  Cami
//
//  Created by Guillaume Coquard on 23/01/25.
//

import AemiUtilities
import Combine
import EventKit
import OSLog
import SwiftUI
import WidgetKit

enum CalendarItemType: CaseIterable {
    case event
    case reminder
}

@Observable
final class DayViewModel: Loggable {
    typealias UpdateAction = (CalendarItemType) -> Void

    var visibleTypes: Set<CalendarItemType> = Set(CalendarItemType.allCases)

    func filter(_ item: EKCalendarItem) -> Bool {
        switch item {
            case is EKEvent: visibleTypes.contains(.event)
            case is EKReminder: visibleTypes.contains(.reminder)
            default: false
        }
    }

    func bound(to type: CalendarItemType) -> Binding<Bool> {
        Binding {
            self.visibleTypes.contains(type)
        } set: { isOn in
            if isOn {
                self.visibleTypes.insert(type)
            } else {
                self.visibleTypes.remove(type)
            }
        }
    }
}

struct SingleDayView: View {
    typealias Model = DayViewModel

    let context: SingleDayContext

    @State private var view = Model()

    var body: some View {
        VStack(spacing: 8) {
            DaySummary(
                date: context.date,
                events: context.filteredEvents,
                reminders: context.filteredReminders,
                bond: view.bound
            )
            .padding(.bottom, 12)
            ForEach(context.combinedItems.filter(view.filter), id: \.calendarItemIdentifier) { item in
                CalendarItemView(item: item)
                    .id(item.calendarItemIdentifier)
            }
        }
        .animation(.default, value: view.visibleTypes)
    }
}
