//
//  Seconds.swift
//  Cami
//
//  Created by Guillaume Coquard on 18/11/23.
//

import Foundation

enum Seconds {
    static func getDays(from seconds: Int) -> Int {
        seconds / (24 * 3600)
    }

    private static var dateFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = .day
        formatter.unitsStyle = .abbreviated
        formatter.calendar?.locale = Locale(identifier: Locale.preferredLanguages.first!)
        return formatter
    }()

    static func formattedDays(from seconds: Int) -> String {
        var component = DateComponents()
        component.day = getDays(from: seconds)
        return dateFormatter.string(from: component)!
    }
}
