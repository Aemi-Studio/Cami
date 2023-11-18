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
        return CamiWidgetEntry(
            events:     CamiHelper.events(calendars: [] as [String]),
            birthdays:  CamiHelper.birthdays()
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
            policy: .after(Calendar.current.date(byAdding: .minute, value: 1, to: Date.now)!)
        )
    }
}
