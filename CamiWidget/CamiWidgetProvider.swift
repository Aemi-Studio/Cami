//
//  CamiWidgetProvider.swift
//  Cami
//
//  Created by Guillaume Coquard on 05/11/23.
//

import SwiftUI
import EventKit
import WidgetKit

struct CamiWidgetProvider: TimelineProvider {

    func placeholder(in context: Context) -> CamiWidgetEntry {
        let (eventMap, birthdays) = CalendarHandler.events()
        return CamiWidgetEntry(
            events: eventMap,
            birthdays: birthdays
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (CamiWidgetEntry) -> Void) {
        let entry: CamiWidgetEntry
        let (eventMap, birthdays) = CalendarHandler.events()

        entry = CamiWidgetEntry(
            events: eventMap,
            birthdays: birthdays
        )
        
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CamiWidgetEntry>) -> Void) {
        let (eventMap, birthdays) = CalendarHandler.events()
        let timeline = Timeline(
            entries: [
                CamiWidgetEntry(
                    events: eventMap,
                    birthdays: birthdays
                )
            ],
            policy: .atEnd
        )
        completion(timeline)
    }

}
