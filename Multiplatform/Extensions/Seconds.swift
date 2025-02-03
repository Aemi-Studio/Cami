//
//  Seconds.swift
//  Cami
//
//  Created by Guillaume Coquard on 18/11/23.
//

import Foundation

extension Seconds {
    var days: Int {
        self / (24 * 3600)
    }

    var toDays: String {
        var component = DateComponents()
        component.day = days

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = .day
        formatter.unitsStyle = .abbreviated
        formatter.calendar?.locale = Locale(identifier: Locale.preferredLanguages.first!)

        return formatter.string(from: component)!
    }
}
