//
//  CamiWidgetIntent.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 03/11/23.
//

import AppIntents
import WidgetKit

struct CamiWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource {
        "Configuration"
    }

    static var description: IntentDescription {
        "Cami Calendar Minimal Widget Configuration"
    }

    @Parameter(
        title: "Complication",
        default: .birthdays,
        optionsProvider: ComplicationOptionsProvider()
    )
    var complication: ComplicationEnum

    @Parameter(title: "Calendars", default: [])
    var calendars: [WidgetCalendarEntity]

    @Parameter(title: "All-Day Inline Calendars", default: [])
    var inlineCalendars: [WidgetCalendarEntity]

    @Parameter(
        title: "All-Day Events Style",
        default: .event,
        optionsProvider: AllDayStyleOptionsProvider()
    )
    var allDayStyle: AllDayStyleEnum

    @Parameter(title: "Group Similar Events", default: true)
    var groupEvents: Bool

    @Parameter(title: "Ongoing Events", default: true)
    var ongoingEvents: Bool

    @Parameter(title: "Show Reminders", default: true)
    var reminders: Bool

    @Parameter(title: "Mix Events & Reminders", default: true)
    var useUnifiedList: Bool

    @Parameter(title: "Header", default: true)
    var showHeader: Bool
}
