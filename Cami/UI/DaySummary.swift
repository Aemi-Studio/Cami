//
//  DaySummary.swift
//  Cami
//
//  Created by Guillaume Coquard on 30/03/25.
//

import EventKit
import SwiftUI

struct DaySummary: View {
    private(set) var events: [EKEvent]
    private(set) var reminders: [EKReminder]

    private(set) var binding: (CalendarItemType) -> Binding<Bool>

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                SummaryCountView(
                    title: String(localized: "summary.count.events"),
                    count: events.count,
                    binding: binding(.event)
                )
                SummaryCountView(
                    title: String(localized: "summary.count.reminders"),
                    count: reminders.count,
                    binding: binding(.reminder)
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollClipDisabled()
        .scrollBounceBehavior(.automatic)
    }
}
