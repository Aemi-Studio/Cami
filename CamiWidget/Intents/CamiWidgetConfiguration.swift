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
        self.allDayStyle            = .event
        self.cornerComplication     = .birthdays
        self.displayOngoingEvents   = true
        self.groupEvents            = true
    }

    init(from intent: CamiWidgetIntent) {
        self.allDayStyle            = intent.allDayStyle
        self.cornerComplication     = intent.cornerComplication
        self.displayOngoingEvents   = intent.displayOngoingEvents
        self.groupEvents            = intent.groupEvents
    }

}
