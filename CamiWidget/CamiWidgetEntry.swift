//
//  CamiWidgetEntry.swift
//  Cami
//
//  Created by Guillaume Coquard on 05/11/23.
//

import WidgetKit

@Observable
final class CamiWidgetEntry: TimelineEntry {

    let date: Date
    let config: CamiWidgetConfiguration
    let calendars: Calendars
    let inlineCalendars: Calendars
    let events: EventDict
    let inlineEvents: EventDict
    let birthdays: Events

    init(
        date: Date                    = Date.now,
        config: CamiWidgetConfiguration = CamiWidgetConfiguration(),
        calendars: Calendars               = [],
        inlineCalendars: Calendars               = [],
        events: EventDict               = [:],
        inlineEvents: EventDict               = [:],
        birthdays: Events                  = []
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
        let date: Date = Date.now
        self.init(
            config: CamiWidgetConfiguration(from: intent),
            calendars: (intent.calendars.map { $0.calendar }).asEKCalendars(),
            inlineCalendars: (intent.inlineCalendars.map { $0.calendar }).asEKCalendars(),
            events: CamiHelper.events(from: intent.calendars, relativeTo: date),
            inlineEvents: CamiHelper.events(from: intent.inlineCalendars, where: { $0.isAllDay }, relativeTo: date),
            birthdays: intent.displayBirthdays
                ? CamiHelper.birthdays(from: date)
                : []
        )
    }
}
