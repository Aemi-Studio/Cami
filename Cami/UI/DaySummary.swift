//
//  DaySummary.swift
//  Cami
//
//  Created by Guillaume Coquard on 30/03/25.
//

import EventKit
import SwiftUI

struct DaySummary: View {
    private(set) var date: Date
    private(set) var events: [EKEvent]
    private(set) var reminders: [EKReminder]

    private(set) var bond: (CalendarItemType) -> Binding<Bool>

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                SummaryCountView(
                    title: String(localized: "summary.count.events"),
                    count: events.count,
                    bound: bond(.event)
                )
                SummaryCountView(
                    title: String(localized: "summary.count.reminders"),
                    count: reminders.count,
                    bound: bond(.reminder)
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollClipDisabled()
        .scrollBounceBehavior(.automatic)
    }
}
