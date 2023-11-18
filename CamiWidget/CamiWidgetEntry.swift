//
//  CamiWidgetEntry.swift
//  Cami
//
//  Created by Guillaume Coquard on 05/11/23.
//

import WidgetKit

final class CamiWidgetEntry: TimelineEntry, ObservableObject {

    let date:               Date
    let config:             CamiWidgetConfiguration
    let calendars:          Calendars
    let inlineCalendars:    Calendars
    let events:             EventDict
    let inlineEvents:       EventDict
    let birthdays:          Events

    init(
        date:               Date                    = Date.now,
        config:             CamiWidgetConfiguration = CamiWidgetConfiguration(),
        calendars:          Calendars               = [],
        inlineCalendars:    Calendars               = [],
        events:             EventDict               = [:],
        inlineEvents:       EventDict               = [:],
        birthdays:          Events                  = []
    ) {
        self.date = date
        self.config = config
        self.calendars = []
        self.inlineCalendars = []
        self.events = events
        self.inlineEvents = inlineEvents
        self.birthdays = birthdays
    }

    convenience init(from intent: CamiWidgetIntent) {
        self.init(
            config: CamiWidgetConfiguration(from: intent),
            calendars: (intent.calendars.map { $0.calendar }).asEKCalendars(),
            inlineCalendars: (intent.inlineCalendars.map { $0.calendar }).asEKCalendars(),
            events: CamiHelper.events(from: intent.calendars),
            inlineEvents: CamiHelper.events(from: intent.inlineCalendars, where: { $0.isAllDay } ),
            birthdays: intent.displayBirthdays
                ? CamiHelper.birthdays()
                : []
        )
    }
}
