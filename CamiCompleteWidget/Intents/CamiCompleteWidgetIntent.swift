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

    @Parameter(title: "Displayed Calendars")
    var calendars: [CamiCalendar]

    @Parameter(
        title: "All-Day Events Style",
        optionsProvider: AllDayEventStyleOptionsProvider()
    )
    var allDayEventStyle: AllDayEventStyle

    init() {
        self.calendars = []
        self.allDayEventStyle = .event
    }

    init(allDayEventStyle: AllDayEventStyle) {
        self.allDayEventStyle = allDayEventStyle
    }

    init(calendars: [CamiCalendar]) {
        self.calendars = calendars
        self.allDayEventStyle = .event
    }

    init(calendars: [CamiCalendar], allDayEventStyle: AllDayEventStyle) {
        self.calendars = calendars
        self.allDayEventStyle = allDayEventStyle
    }
    
}

struct CamiCalendar: AppEntity {
    var id: String
    var calendar: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Calendar"
    static var defaultQuery = CamiCalendarQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(id)")
    }

    static let allCalendars: [CamiCalendar] = CamiHelper.allCalendars.map { calendar in
        CamiCalendar(
            id: "\(calendar.source.title) - \(calendar.title)",
            calendar: calendar.calendarIdentifier
        )
    }
}

struct CamiCalendarQuery: EntityQuery {
    typealias Entity = CamiCalendar

    func entities(for identifiers: [Entity.ID]) async throws -> [Entity] {
        CamiCalendar.allCalendars.filter { calendar in
            identifiers.contains(calendar.id)
        }
    }

    func suggestedEntities() async throws -> [Entity] {
        CamiCalendar.allCalendars
    }

    func defaultResult() async -> [Entity] {
        CamiCalendar.allCalendars
    }
}

struct AllDayEventStyleOptionsProvider: DynamicOptionsProvider {
    func results() async throws -> [AllDayEventStyle] {
        AllDayEventStyle.allCases
    }
}
