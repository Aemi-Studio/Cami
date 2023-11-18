//
//  CamiWidgetIntent.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 03/11/23.
//

import WidgetKit
import AppIntents

struct CamiWidgetIntent: WidgetConfigurationIntent {

    static let title: LocalizedStringResource = "Configuration"
    static let description = IntentDescription("Cami Calendar Minimal Widget Configuration")

    @Parameter(title: "Calendars", default: [])
    var calendars: [WidgetCalendarEntity]

    @Parameter(
        title: "All-Day Events Style",
        default: .event,
        optionsProvider: AllDayStyleOptionsProvider()
    )
    var allDayStyle: AllDayStyleEnum

    @Parameter(title: "Display Birthdays", default: true)
    var displayBirthdays: Bool

    @Parameter(title: "Group Similar Events", default: true)
    var groupEvents: Bool

}
