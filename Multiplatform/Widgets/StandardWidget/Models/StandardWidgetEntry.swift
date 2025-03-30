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

    init(
        date: Date = Date.now,
        configuration: Configuration = .default,
        calendars: [Calendar],
        inlineCalendars: [Calendar]
    ) {
        self.date = date
        self.configuration = configuration
        self.calendars = calendars.isEmpty ? DataContext.shared.calendars.map(\.calendarIdentifier) : calendars
        self.inlineCalendars = inlineCalendars.isEmpty ? DataContext.shared.calendars
            .map(\.calendarIdentifier) : inlineCalendars
    }
}

extension StandardWidgetEntry {
    static var `default`: Self {
        .init(
            date: .now,
            configuration: .default,
            calendars: DataContext.shared.calendars.map(\.calendarIdentifier),
            inlineCalendars: DataContext.shared.calendars.map(\.calendarIdentifier)
        )
    }
}
