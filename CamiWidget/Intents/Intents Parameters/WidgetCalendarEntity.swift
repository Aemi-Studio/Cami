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

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Calendar"
    static var defaultQuery = CamiCalendarQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(id)")
    }

    static let allCalendars: [WidgetCalendarEntity] = DataContext.shared.calendars.map { calendar in
        WidgetCalendarEntity(
            id: "\(calendar.source.title) - \(calendar.title)",
            calendar: calendar.calendarIdentifier
        )
    }
}

struct CamiCalendarQuery: EntityQuery {
    typealias Entity = WidgetCalendarEntity

    func entities(for identifiers: [Entity.ID]) async throws -> [Entity] {
        WidgetCalendarEntity.allCalendars.filter { calendar in
            identifiers.contains(calendar.id)
        }
    }

    func suggestedEntities() async throws -> [Entity] {
        WidgetCalendarEntity.allCalendars
    }

    func defaultResult() async -> [Entity] {
        WidgetCalendarEntity.allCalendars
    }
}
