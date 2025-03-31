//
//  StandardWidgetEntry+TimelineEntry.swift
//  Cami
//
//  Created by Guillaume Coquard on 05/11/23.
//

import EventKit
import WidgetKit

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
