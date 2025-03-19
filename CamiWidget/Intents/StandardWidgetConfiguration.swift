//
//  StandardWidgetConfiguration.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 18/11/23.
//

import Foundation

final class StandardWidgetConfiguration {
    let allDayStyle: AllDayStyleEnum
    let complication: ComplicationEnum
    let showReminders: Bool
    let showHeader: Bool
    let useUnifiedList: Bool
    let showOngoingEvents: Bool
    let groupEvents: Bool

    init() {
        allDayStyle = .event
        complication = .birthdays
        showHeader = true
        showReminders = true
        useUnifiedList = true
        showOngoingEvents = true
        groupEvents = true
    }

    init(from intent: CamiWidgetIntent) {
        allDayStyle = intent.allDayStyle
        complication = intent.complication
        showHeader = intent.showHeader
        showReminders = intent.reminders
        useUnifiedList = intent.useUnifiedList
        showOngoingEvents = intent.ongoingEvents
        groupEvents = intent.groupEvents
    }
}

extension StandardWidgetConfiguration {
    static let `default` = StandardWidgetConfiguration()
}
