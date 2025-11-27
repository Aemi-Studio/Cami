//
//  SingleDayView.swift
//  Cami
//
//  Created by Guillaume Coquard on 23/01/25.
//

import AemiUtilities
import EventKit
import OSLog
import SwiftUI
import WidgetKit

struct SingleDayView: View {
    typealias Model = DayViewModel

    @Environment(\.presentation) private var presentation

    let context: SingleDayContext

    @LazyState private var view = Model()
    @State private var hasAppeared = false

    private var filteredItems: [EKCalendarItem] {
        context.combinedItems.filter(view.filter)
    }

    var body: some View {
        VStack(spacing: 8) {
            DaySummary(
                model: $view,
                events: context.filteredEvents,
                reminders: context.filteredReminders
            )
            .padding(.bottom, 18)

            ForEach(Array(filteredItems.enumerated()), id: \.element.calendarItemIdentifier) { index, item in
                CalendarItemView(item: item)
                    .transition(
                        .asymmetric(
                            insertion: .opacity
                                .combined(with: .move(edge: .bottom))
                                .combined(with: .scale(scale: 0.95)),
                            removal: .opacity.combined(with: .scale(scale: 0.95))
                        )
                    )
                    .scrollTransition(.interactive) { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.8)
                            .scaleEffect(phase.isIdentity ? 1 : 0.98)
                            .offset(y: phase.isIdentity ? 0 : phase.value * 10)
                    }
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(y: hasAppeared ? 0 : 20)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.8)
                        .delay(Double(index) * 0.05),
                        value: hasAppeared
                    )
            }
        }
        .animation(.default, value: view.visibleTypes)
        .onAppear {
            withAnimation {
                hasAppeared = true
            }
        }
    }
}
