//
//  DaySummary.swift
//  Cami
//
//  Created by Guillaume Coquard on 30/03/25.
//

import EventKit
import SwiftUI

struct DaySummary: View {

    @Binding private(set) var model: DayViewModel

    private(set) var events: [EKEvent]
    private(set) var reminders: [EKReminder]

    @State private var hasAppeared = false

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                SummaryCountView(
                    kind: .event,
                    count: events.count,
                    binding: model.bound(to: .event)
                )
                .opacity(hasAppeared ? 1 : 0)
                .offset(x: hasAppeared ? 0 : -20)
                .animation(
                    .spring(response: 0.4, dampingFraction: 0.75).delay(0.05),
                    value: hasAppeared
                )

                SummaryCountView(
                    kind: .reminder,
                    count: reminders.count,
                    binding: model.bound(to: .reminder)
                )
                .opacity(hasAppeared ? 1 : 0)
                .offset(x: hasAppeared ? 0 : -20)
                .animation(
                    .spring(response: 0.4, dampingFraction: 0.75).delay(0.1),
                    value: hasAppeared
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollClipDisabled()
        .scrollBounceBehavior(.automatic)
        .onAppear {
            hasAppeared = true
        }
    }
}
