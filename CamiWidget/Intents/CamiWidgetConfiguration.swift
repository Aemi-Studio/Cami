//
//  CamiWidgetConfiguration.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 18/11/23.
//

import Foundation

final class CamiWidgetConfiguration {

    let allDayStyle:       AllDayStyleEnum
    let displayBirthdays:  Bool
    let groupEvents:       Bool

    init() {
        self.allDayStyle        = .event
        self.displayBirthdays   = true
        self.groupEvents        = true
    }

    init(from intent: CamiWidgetIntent) {
        self.allDayStyle        = intent.allDayStyle
        self.displayBirthdays   = intent.displayBirthdays
        self.groupEvents        = intent.groupEvents
    }

}
