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

struct SingleDayView: View {
    typealias Model = DayViewModel

    @Environment(\.presentation) private var presentation

    let context: SingleDayContext

    @LazyState private var view = Model()

    var body: some View {
        VStack(spacing: 8) {
            DaySummary(
                model: $view,
                events: context.filteredEvents,
                reminders: context.filteredReminders
            )
            .padding(.bottom, 18)

            ForEach(
                context.combinedItems.filter(view.filter),
                id: \.calendarItemIdentifier,
                content: CalendarItemView.init
            )
        }
        .animation(.default, value: view.visibleTypes)
    }
}
