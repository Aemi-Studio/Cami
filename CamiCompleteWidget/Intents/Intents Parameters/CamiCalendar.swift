//
//  CamiCalendar.swift
//  Cami
//
//  Created by Guillaume Coquard on 18/11/23.
//

import Foundation
import AppIntents

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
