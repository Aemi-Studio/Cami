//
//  StandardWidgetEntry.swift
//  Cami
//
//  Created by Guillaume Coquard on 05/11/23.
//

import WidgetKit
import EventKit

extension StandardWidgetEntry: TimelineEntry {
    typealias Intent = CamiWidgetIntent

    init(from intent: Intent) {
        self.init(
            date: .now,
            configuration: Configuration(from: intent),
            calendars: intent.calendars.map(\.calendar),
            inlineCalendars: intent.inlineCalendars.map(\.calendar)
        )
    }
}
