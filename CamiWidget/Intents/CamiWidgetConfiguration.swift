//
//  CamiWidgetConfiguration.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 18/11/23.
//

import Foundation

final class CamiWidgetConfiguration {
    let allDayStyle: AllDayStyleEnum
    let cornerComplication: CornerComplicationEnum
    let displayOngoingEvents: Bool
    let groupEvents: Bool

    init() {
        allDayStyle = .event
        cornerComplication = .birthdays
        displayOngoingEvents = true
        groupEvents = true
    }

    init(from intent: CamiWidgetIntent) {
        allDayStyle = intent.allDayStyle
        cornerComplication = intent.cornerComplication
        displayOngoingEvents = intent.displayOngoingEvents
        groupEvents = intent.groupEvents
    }
}
