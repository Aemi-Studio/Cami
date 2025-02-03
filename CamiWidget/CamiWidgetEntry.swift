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
    let events: CIDict
    let inlineEvents: CIDict
    let birthdays: CItems
    let reminders: CItems

    init(
        date: Date = Date.now,
        config: CamiWidgetConfiguration = CamiWidgetConfiguration(),
        calendars _: Calendars = [],
        inlineCalendars _: Calendars = [],
        events: CIDict = [:],
        inlineEvents: CIDict = [:],
        birthdays: CItems = [],
        reminders: CItems = []
    ) {
        self.date = date
        self.config = config
        calendars = []
        inlineCalendars = []
        self.events = events
        self.inlineEvents = inlineEvents
        self.birthdays = birthdays
        self.reminders = reminders
    }

    convenience init(from intent: CamiWidgetIntent) {
        let date = Date.now
        self.init(
            config: CamiWidgetConfiguration(from: intent),
            calendars: (intent.calendars.map { $0.calendar }).asEKCalendars(),
            inlineCalendars: (intent.inlineCalendars.map { $0.calendar }).asEKCalendars(),
            events: DataContext.shared.events(from: intent.calendars, relativeTo: date),
            inlineEvents: DataContext.shared.events(
                from: intent.inlineCalendars, where: { $0.isAllDay }, relativeTo: date
            ),
            birthdays: intent.cornerComplication == .birthdays
                ? DataContext.shared.birthdays(from: date)
                : [],
            reminders: DataContext.shared.reminders(where: Filters.any(of: [Filters.dueToday, Filters.open]).filter)
        )
    }
}
