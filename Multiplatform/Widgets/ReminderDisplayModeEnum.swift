//
//  ReminderDisplayModeEnum.swift
//  Cami
//
//  Created by Guillaume Coquard on 27/11/25.
//

import AppIntents
import Foundation

enum ReminderDisplayModeEnum: String, CaseIterable, AppEnum, WidgetEnumParameter {
    typealias RawValue = String

    /// Show only reminders due today
    case todayOnly = "Today Only"

    /// Show reminders due today and overdue ones
    case todayAndOverdue = "Today & Overdue"

    /// Show all upcoming reminders (with due dates)
    case upcoming = "Upcoming"

    static let localizedTitle = String(localized: "intentParameter.reminderDisplayMode.title")

    static let typeDisplayRepresentation: TypeDisplayRepresentation = .init(stringLiteral: "Display Mode")

    static let caseDisplayRepresentations: [ReminderDisplayModeEnum: DisplayRepresentation] = [
        .todayOnly: .init(stringLiteral: "Today Only"),
        .todayAndOverdue: .init(stringLiteral: "Today & Overdue"),
        .upcoming: .init(stringLiteral: "All Upcoming")
    ]

    var title: String {
        rawValue
    }
}
