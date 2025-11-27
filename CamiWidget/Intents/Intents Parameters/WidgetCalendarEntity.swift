//
//  WidgetCalendarEntity.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 18/11/23.
//

import AppIntents
import Foundation

struct WidgetCalendarEntity: AppEntity {
    var id: String
    var calendar: String

    static let localizedTitle = String(localized: "intentParameter.calendarSelection.title")
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Calendar"
    static var defaultQuery = CamiCalendarQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(id)")
    }

    @MainActor
    static func fetchAllCalendars() -> [WidgetCalendarEntity] {
        DataContext.shared.calendars.map { calendar in
            WidgetCalendarEntity(
                id: "\(calendar.source.title) - \(calendar.title)",
                calendar: calendar.calendarIdentifier
            )
        }
    }
}

struct CamiCalendarQuery: EntityQuery {
    typealias Entity = WidgetCalendarEntity

    func entities(for identifiers: [Entity.ID]) async throws -> [Entity] {
        let allCalendars = await WidgetCalendarEntity.fetchAllCalendars()
        return allCalendars.filter { calendar in
            identifiers.contains(calendar.id)
        }
    }

    func suggestedEntities() async throws -> [Entity] {
        await WidgetCalendarEntity.fetchAllCalendars()
    }

    func defaultResult() async -> [Entity] {
        await WidgetCalendarEntity.fetchAllCalendars()
    }
}
