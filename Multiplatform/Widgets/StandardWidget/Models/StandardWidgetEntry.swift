//
//  StandardWidgetEntry.swift
//  Cami
//
//  Created by Guillaume Coquard on 10/03/25.
//

import EventKit
import Foundation
import SwiftUI

struct StandardWidgetEntry {
    typealias Configuration = StandardWidgetConfiguration
    typealias Calendar = String

    let date: Date
    var configuration: Configuration
    let calendars: [Calendar]
    let inlineCalendars: [Calendar]

    /// Pre-populated content for the widget (fetched in provider)
    let content: StandardWidgetContent

    init(
        date: Date = Date.now,
        configuration: Configuration = .default,
        calendars: [Calendar],
        inlineCalendars: [Calendar],
        content: StandardWidgetContent? = nil
    ) {
        self.date = date
        self.configuration = configuration
        self.calendars = calendars
        self.inlineCalendars = inlineCalendars
        // Use provided content or create empty default
        self.content = content ?? StandardWidgetContent(
            date: date,
            configuration: configuration,
            birthdays: [],
            items: [:],
            inlineEvents: [:]
        )
    }
}

extension StandardWidgetEntry {
    /// Synchronous default for placeholder/environment values (uses empty calendars)
    static var `default`: Self {
        .init(
            date: .now,
            configuration: .default,
            calendars: [],
            inlineCalendars: []
        )
    }

    @MainActor
    static func makeDefault() async -> Self {
        let calendars = DataContext.shared.calendars.map(\.calendarIdentifier)
        return .init(
            date: .now,
            configuration: .default,
            calendars: calendars,
            inlineCalendars: calendars
        )
    }
}
