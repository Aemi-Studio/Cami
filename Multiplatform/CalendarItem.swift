//
//  CalendarItem.swift
//  Cami
//
//  Created by Guillaume Coquard on 16/03/25.
//

import EventKit

struct CalendarItem {
    typealias Kind = CalendarItemKind

    let id: String
    let kind: Kind
    let title: String
    let calendar: String
    let color: CGColor!

    let isAllDay: Bool

    let start: Date?
    let end: Date?
    let due: Date?

    let contactIdentifier: String?

    init?(from item: EKCalendarItem) {
        if let event = item as? EKEvent {
            self = CalendarItem(from: event)
        } else if let reminder = item as? EKReminder, let item = CalendarItem(from: reminder) {
            self = item
        } else {
            return nil
        }
    }

    public enum CalendarItemKind: Int, Hashable, CaseIterable {
        case event
        case reminder
    }

    var boundStart: Date! {
        switch kind {
            case .event: start
            case .reminder: due
        }
    }

    var boundEnd: Date {
        end ?? boundStart
    }
}

extension CalendarItem {
    init(from event: EKEvent) {
        self.id = event.calendarItemIdentifier
        self.kind = .event
        self.isAllDay = event.isAllDay
        self.start = event.startDate
        self.end = event.endDate
        self.due = nil
        self.calendar = event.calendar.calendarIdentifier
        self.color = event.calendar.cgColor
        self.title = event.title ?? ""
        self.contactIdentifier = event.birthdayContactIdentifier
    }
}

extension CalendarItem {
    init?(from reminder: EKReminder) {
        guard let dueDate = reminder.dueDateComponents?.date else { return nil }
        self.id = reminder.calendarItemIdentifier
        self.kind = .reminder
        self.isAllDay = false
        self.start = nil
        self.end = reminder.completionDate
        self.due = dueDate
        self.calendar = reminder.calendar.calendarIdentifier
        self.color = reminder.calendar.cgColor
        self.title = reminder.title ?? ""
        self.contactIdentifier = nil
    }
}

extension CalendarItem: Identifiable, Hashable, Sendable, Equatable {}

extension CalendarItem: Comparable {
    static func < (lhs: CalendarItem, rhs: CalendarItem) -> Bool {
        if lhs.boundStart != rhs.boundStart {
            return lhs.boundStart < lhs.boundStart
        }
        return lhs.title < rhs.title
    }
}

extension CalendarItem {
    var isStartingToday: Bool {
        boundStart.isToday
    }

    var isEndingToday: Bool {
        boundEnd.isToday
    }

    func continuesPast(_ date: Date) -> Bool {
        let resetDate = boundStart.zero
        let tomorrow = Calendar.current.date(byAdding: DateComponents(day: 1), to: date)!
        return resetDate < date.zero || (isStartingToday && boundEnd.zero > tomorrow)
    }

    func isSameDay(as event: CalendarItem) -> Bool {
        let hasSameStartDate = boundStart.zero == event.boundStart.zero
        let hasSameEndDate = boundEnd.zero == event.boundEnd.zero
        return hasSameStartDate || hasSameEndDate
    }

    func isStrictlySameDay(as event: CalendarItem) -> Bool {
        let hasSameStartDate: Bool = boundStart.zero == event.boundStart.zero
        let hasSameEndDate: Bool = boundEnd.zero == event.boundEnd.zero
        return hasSameStartDate && hasSameEndDate
    }
}

extension Collection where Element == CalendarItem {
    func sorted(_ order: ComparisonResult = .orderedAscending) -> [Element] {
        sorted(by: { first, second in
            switch order {
                case .orderedAscending: first < second
                case .orderedDescending: first > second
                case .orderedSame: first == second
            }
        })
    }

    func mapped(relativeTo date: Date) -> [Date: [Element]] {
        var itemsDictionary = [Date: [Element]]()
        let yesterday = (date + DateComponents(day: -1)).zero
        for item in self {
            if item.continuesPast(date) {
                itemsDictionary.append(to: yesterday, item)
            } else {
                itemsDictionary.append(to: item.boundStart.zero, item)
            }
        }
        return itemsDictionary
    }

    func similarElementsWithinSameCalendar(_ item: Element) -> [(offset: Int, element: Element)] {
        enumerated().filter { (_, element) in
            element.kind == item.kind &&
                element.id != item.id &&
                element.title == item.title &&
                element.calendar == item.calendar
        }
    }

    func grouped() -> [[Element]] {
        var result = [[Element]]()
        var ignoredEvents = Set<Int>()

        let elements = sorted()

        for (index, item) in elements.enumerated() where !ignoredEvents.contains(index) {
            guard item.kind == .event else {
                result.append([item])
                continue
            }

            let similarElements = elements.similarElementsWithinSameCalendar(item)

            ignoredEvents.formUnion(similarElements.map(\.offset))

            result.append([item] + similarElements.map(\.element))
        }
        return result
    }
}

extension [Date: [CalendarItem]] {
    func filter(where predicate: @escaping (CalendarItem) -> Bool) -> Self {
        var dictionary = Self()
        for (date, items) in self {
            let filtered = items.filter(predicate)
            if !filtered.isEmpty {
                dictionary[date] = filtered
            }
        }
        return dictionary
    }

    static func + (lhs: Self, rhs: Self) -> Self {
        var result = lhs
        for (date, items) in rhs {
            result[date, default: []].append(contentsOf: items)
        }
        for (date, items) in result {
            if items.isEmpty {
                result.removeValue(forKey: date)
            } else {
                result.updateValue(
                    Array(Set(items)).sorted(by: { $0.boundStart < $1.boundStart }),
                    forKey: date
                )
            }
        }
        return result
    }

    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }

    mutating func append(to date: Date, _ item: CalendarItem) {
        if var list = self[date] {
            list.insert(
                item,
                at: list.firstIndex { $0.boundStart >= item.boundStart } ?? list.endIndex
            )
            self.updateValue(list, forKey: date)
        } else {
            self[date] = [item]
        }
    }
}
