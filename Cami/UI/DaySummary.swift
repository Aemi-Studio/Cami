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

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                SummaryCountView(
                    kind: .event,
                    count: events.count,
                    binding: model.bound(to: .event)
                )
                SummaryCountView(
                    kind: .reminder,
                    count: reminders.count,
                    binding: model.bound(to: .reminder)
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollClipDisabled()
        .scrollBounceBehavior(.automatic)
    }
}
