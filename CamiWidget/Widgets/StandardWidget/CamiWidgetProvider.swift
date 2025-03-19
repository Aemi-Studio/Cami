//
//  CamiWidgetProvider.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 05/11/23.
//

import WidgetKit

struct CamiWidgetProvider: AppIntentTimelineProvider {
    typealias Entry = StandardWidgetEntry
    typealias Intent = CamiWidgetIntent

    func placeholder(in _: Context) -> Entry {
        let calendars = DataContext.shared.calendars.map(\.calendarIdentifier)
        return StandardWidgetEntry(
            date: .now,
            calendars: calendars,
            inlineCalendars: calendars
        )
    }

    func snapshot(for intent: Intent, in _: Context) async -> Entry {
        StandardWidgetEntry(from: intent)
    }

    func timeline(for intent: Intent, in _: Context) async -> Timeline<Entry> {
        Timeline(
            entries: [StandardWidgetEntry(from: intent)],
            policy: .atEnd
        )
    }
}
