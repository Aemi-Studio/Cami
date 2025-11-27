//
//  CalendarItemKind.swift
//  Cami
//
//  Created by Guillaume Coquard on 27/11/25.
//

import Foundation

/// Represents the type of calendar item (event, reminder, or streak).
enum CalendarItemKind: Int, Hashable, CaseIterable, Codable, Sendable {
    case event
    case reminder
    case streak
}

extension CalendarItemKind: CustomStringConvertible {
    var description: String {
        switch self {
        case .event:
            String(localized: "calendarItem.kind.event")
        case .reminder:
            String(localized: "calendarItem.kind.reminder")
        case .streak:
            String(localized: "calendarItem.kind.streak")
        }
    }

    var pluralDescription: String {
        switch self {
        case .event:
            String(localized: "calendarItem.kind.event.plural")
        case .reminder:
            String(localized: "calendarItem.kind.reminder.plural")
        case .streak:
            String(localized: "calendarItem.kind.streak.plural")
        }
    }

    var listDescription: String {
        switch self {
        case .event:
            String(localized: "calendarItem.kind.event.list")
        case .reminder:
            String(localized: "calendarItem.kind.reminder.list")
        case .streak:
            String(localized: "calendarItem.kind.streak.list")
        }
    }

    var listPluralDescription: String {
        switch self {
        case .event:
            String(localized: "calendarItem.kind.event.list.plural")
        case .reminder:
            String(localized: "calendarItem.kind.reminder.list.plural")
        case .streak:
            String(localized: "calendarItem.kind.streak.list.plural")
        }
    }

    var listSystemImage: String {
        switch self {
        case .event:
            "calendar"
        case .reminder:
            "checklist"
        case .streak:
            "circle.grid.2x1.left.filled"
        }
    }
}
