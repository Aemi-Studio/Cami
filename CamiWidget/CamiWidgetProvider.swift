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
            events: CamiHelper.events(from: [] as [String], relativeTo: date),
            birthdays: CamiHelper.birthdays(from: date)
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
