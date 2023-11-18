//
//  CamiCompleteWidgetIntent.swift
//  CamiCompleteWidget
//
//  Created by Guillaume Coquard on 03/11/23.
//

import WidgetKit
import EventKit
import AppIntents

struct CamiCompleteWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")

    @Parameter(title: "Calendars", default: [])
    var calendars: [CamiCalendar]

    @Parameter(
        title: "All-Day Events Style",
        default: .event,
        optionsProvider: AllDayEventStyleOptionsProvider()
    )
    var allDayEventStyle: AllDayEventStyle

    @Parameter(title: "Display Birthdays", default: true)
    var displayBirthdays: Bool

    @Parameter(title: "Group Similar Events", default: true)
    var groupEvents: Bool

}
