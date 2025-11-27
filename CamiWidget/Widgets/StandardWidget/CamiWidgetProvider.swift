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
        // Return placeholder with empty calendars - will be populated in snapshot/timeline
        StandardWidgetEntry(
            date: .now,
            calendars: [],
            inlineCalendars: []
        )
    }

    func snapshot(for intent: Intent, in _: Context) async -> Entry {
        await createEntry(from: intent)
    }

    func timeline(for intent: Intent, in _: Context) async -> Timeline<Entry> {
        let entry = await createEntry(from: intent)
        return Timeline(entries: [entry], policy: .atEnd)
    }

    @MainActor
    private func createEntry(from intent: Intent) async -> Entry {
        // Create base entry without content
        let baseEntry = StandardWidgetEntry(from: intent)

        // Fetch populated content asynchronously
        let content = await StandardWidgetContent.create(from: baseEntry)

        // Return entry with populated content
        return StandardWidgetEntry(
            date: baseEntry.date,
            configuration: baseEntry.configuration,
            calendars: baseEntry.calendars,
            inlineCalendars: baseEntry.inlineCalendars,
            content: content
        )
    }
}
