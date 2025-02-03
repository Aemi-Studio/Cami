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

    @Parameter(
        title: "Corner Complication",
        default: .birthdays,
        optionsProvider: CornerComplicationOptionsProvider()
    )
    var cornerComplication: CornerComplicationEnum

    @Parameter(title: "Display Ongoing Events", default: true)
    var displayOngoingEvents: Bool
}
