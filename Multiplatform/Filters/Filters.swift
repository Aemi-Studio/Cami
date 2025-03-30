//
//  Filters.swift
//  Cami
//
//  Created by Guillaume Coquard on 25/01/25.
//

import EventKit
import Foundation

enum Filters: CaseIterable {
    static var allCases: [Filters] {
        [
            .due(on: nil),
            .dueLater,
            .dueToday,
            .overdue,
            .done,
            .open,
            .happensToday
        ]
    }

    case due(on: Date? = nil)
    case dueLater
    case dueToday
    case overdue
    case done
    case open

    case happensToday

    private enum Values {
        // MARK: - Reminders Filters

        static var due: Filter {
            Filter(
                type: .reminder,
                filter: { ($0 as? EKReminder)?.dueDateComponents != nil },
                localizedDescription: String(localized: "Has Due Date")
            )
        }

        static func due(on date: Date) -> Filter {
            Filter(
                type: .reminder,
                filter: { ($0 as? EKReminder)?.dueDateComponents?.date?.zero == date.zero },
                localizedDescription: String(localized: "Has Due Date")
            )
        }

        static var dueLater: Filter {
            Filter(
                type: .reminder,
                filter: { ($0 as? EKReminder)?.dueDateComponents?.date ?? .now > .now },
                localizedDescription: String(localized: "Due Later")
            )
        }

        static var dueToday: Filter {
            Filter(
                type: .reminder,
                filter: { reminder in
                    if let reminder = reminder as? EKReminder,
                       reminder.dueDateComponents?.date?.isToday == .some(true),
                       !reminder.isCompleted {
                        return true
                    }
                    return false
                },
                localizedDescription: String(localized: "Due Today")
            )
        }

        static var overdue: Filter {
            Filter(
                type: .reminder,
                filter: { reminder in
                    if let reminder = reminder as? EKReminder, let date = reminder.dueDateComponents?.date {
                        date < .now && !reminder.isCompleted
                    } else {
                        false
                    }
                },
                localizedDescription: String(localized: "Overdue")
            )
        }

        static var done: Filter {
            Filter(
                type: .reminder,
                filter: { reminder in
                    if let reminder = reminder as? EKReminder {
                        reminder.isCompleted
                    } else {
                        false
                    }
                },
                localizedDescription: String(localized: "Done")
            )
        }

        static var open: Filter {
            Filter(
                type: .reminder,
                filter: { reminder in
                    if let reminder = reminder as? EKReminder {
                        !reminder.isCompleted
                    } else {
                        false
                    }
                },
                localizedDescription: String(localized: "Open")
            )
        }

        // MARK: - Events Filters

        static var happensToday: Filter {
            Filter(
                type: .event,
                filter: { event in
                    if let event = event as? EKEvent {
                        let isToday = event.startDate.isToday == .some(true)
                        let zero = Date.now.zero
                        let startedBefore = event.startDate < zero
                        let spansToday = event.endDate > zero
                        return isToday || (startedBefore && spansToday)
                    }
                    return false
                },
                localizedDescription: String(localized: "Happens Today")
            )
        }
    }
}

extension Filters: Filtering {
    fileprivate var filter: Filter {
        switch self {
            case .due(let date): date == nil ? Values.due : Values.due(on: date!)
            case .dueLater: Values.dueLater
            case .dueToday: Values.dueToday
            case .overdue: Values.overdue
            case .done: Values.done
            case .open: Values.open
            case .happensToday: Values.happensToday
        }
    }

    func callAsFunction(_ item: EKCalendarItem) -> Bool {
        filter.filter(item)
    }

    var callable: (EKCalendarItem) -> Bool {
        { self($0) }
    }

    func filter(item: EKCalendarItem) -> Bool {
        self(item)
    }
}

extension Filters {
    static func any<T: Filtering>(of filters: [T]) -> Filtering {
        guard let filters = (filters as? [Filters]) else {
            return Filter(type: .all, filter: { _ in false }, localizedDescription: "")
        }
        let allTypes = Set(filters.map(\.filter).map(\.type))
        let type: Filter.Target = allTypes.count == 1 ? allTypes.first! : .all
        return Filter(
            type: type,
            filter: { item in filters.contains(where: { $0.filter(item: item) }) },
            localizedDescription: filters.map(\.filter).map(\.localizedDescription).joined(separator: "|")
        )
    }

    static func all<T: Filtering>(of filters: [T]) -> Filtering {
        guard let filters = (filters as? [Filters]) else {
            return Filter(type: .all, filter: { _ in false }, localizedDescription: "")
        }
        let allTypes = Set(filters.map(\.filter).map(\.type))
        let type: Filter.Target = allTypes.count == 1 ? allTypes.first! : .all
        return Filter(
            type: type,
            filter: { item in filters.allSatisfy { $0.filter(item: item) } },
            localizedDescription: filters.map(\.filter).map(\.localizedDescription).joined(separator: "|")
        )
    }

    static func none<T: Filtering>(of filters: [T]) -> Filtering {
        guard let filters = (filters as? [Filters]) else {
            return Filter(type: .all, filter: { _ in false }, localizedDescription: "")
        }
        let allTypes = Set(filters.map(\.filter).map(\.type))
        let type: Filter.Target = allTypes.count == 1 ? allTypes.first! : .all
        return Filter(
            type: type,
            filter: { item in filters.allSatisfy { !$0.filter(item: item) } },
            localizedDescription: filters.map(\.filter).map(\.localizedDescription).joined(separator: "|")
        )
    }
}
