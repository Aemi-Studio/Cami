//
//  CamiWidgetProvider.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 05/11/23.
//

import WidgetKit

struct CamiWidgetProvider: AppIntentTimelineProvider {

    typealias Entry = CamiWidgetEntry
    typealias Intent = CamiWidgetIntent

    func placeholder(in context: Context) -> Entry {
        let date: Date = Date.now
        return CamiWidgetEntry(
            events: DataContext.shared.events(from: [String](), relativeTo: date),
            birthdays: DataContext.shared.birthdays(from: date),
            reminders: DataContext.shared.reminders(where: Filters.any(of: [Filters.open, Filters.dueToday]).filter)
        )
    }

    func snapshot(for intent: Intent, in context: Context) async -> Entry {
        CamiWidgetEntry(from: intent)
    }

    func timeline(for intent: Intent, in context: Context) async -> Timeline<Entry> {
        Timeline(
            entries: [
                CamiWidgetEntry(from: intent)
            ],
            policy: .atEnd
        )
    }
}
