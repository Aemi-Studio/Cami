//
//  Filter.swift
//  Cami
//
//  Created by Guillaume Coquard on 25/01/25.
//

import EventKit
import Foundation

struct Filter: Filtering, Equatable {
    static func == (lhs: Filter, rhs: Filter) -> Bool {
        lhs.type == rhs.type &&
            lhs.localizedDescription == rhs.localizedDescription
    }

    enum Target {
        case event
        case reminder
        case all
    }

    var type: Target
    var filter: (EKCalendarItem) -> Bool
    var localizedDescription: String

    func filter(item: EKCalendarItem) -> Bool {
        switch type {
            case .event:
                guard let event = item as? EKEvent else {
                    return true
                }
                return filter(event)
            case .reminder:
                guard let reminder = item as? EKReminder else {
                    return true
                }
                return filter(reminder)
            case .all:
                return filter(item)
        }
    }
}
