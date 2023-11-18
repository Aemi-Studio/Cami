//
//  CamiWidgetEntry.swift
//  Cami
//
//  Created by Guillaume Coquard on 05/11/23.
//

import WidgetKit

final class CamiWidgetEntry: TimelineEntry, ObservableObject {

    let date:       Date
    let config:     CamiWidgetConfiguration
    let events:     EventDict
    let birthdays:  Events

    init(
        date:       Date                    = Date.now,
        config:     CamiWidgetConfiguration = CamiWidgetConfiguration(),
        events:     EventDict               = [:],
        birthdays:  Events                  = []
    ) {
        self.date = date
        self.config = config
        self.events = events
        self.birthdays = birthdays
    }

    convenience init(from intent: CamiWidgetIntent) {
        self.init(
            config: CamiWidgetConfiguration(from: intent),
            events: CamiHelper.events(
                calendars: intent.calendars
            ),
            birthdays: intent.displayBirthdays
                ? CamiHelper.birthdays()
                : []
        )
    }
}
