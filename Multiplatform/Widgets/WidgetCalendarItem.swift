//
//  WidgetCalendarItem.swift
//  Cami
//
//  Created by Guillaume Coquard on 28/09/25.
//

import EventKit
import Foundation

/// A lightweight, Sendable representation of calendar items for widget use.
///
/// Since `EKEvent` and `EKReminder` are not Sendable, this struct captures
/// the essential data needed for widget display and can be safely passed
/// across concurrency boundaries.
struct WidgetCalendarItem {
    let id: String
    let kind: Kind
    let title: String
    let calendarId: String
    let color: CGColor

    let isAllDay: Bool
    let startDate: Date?
    let endDate: Date?

    /// For birthday events, the contact identifier
    let contactIdentifier: String?

    enum Kind: UInt8, Sendable, CaseIterable {
        case event = 0
        case reminder = 1
        case birthday = 2
    }

    var boundStart: Date {
        startDate ?? endDate ?? .distantPast
    }

    var boundEnd: Date {
        endDate ?? startDate ?? .distantFuture
    }

    var isStartingToday: Bool {
        boundStart.isToday
    }

    var isEndingToday: Bool {
        boundEnd.isToday
    }
}

extension WidgetCalendarItem: Identifiable, Hashable, Sendable, Equatable {}

extension WidgetCalendarItem: Comparable {
    static func < (lhs: WidgetCalendarItem, rhs: WidgetCalendarItem) -> Bool {
        if lhs.boundStart != rhs.boundStart {
            return lhs.boundStart < rhs.boundStart
        }
        return lhs.title < rhs.title
    }
}

// MARK: - EventKit Initializers

extension WidgetCalendarItem {
    /// Creates a widget calendar item from an EKEvent
    init(from event: EKEvent) {
        self.id = event.calendarItemIdentifier
        self.title = event.title ?? ""
        self.calendarId = event.calendar.calendarIdentifier
        self.color = event.calendar.cgColor
        self.isAllDay = event.isAllDay
        self.startDate = event.startDate
        self.endDate = event.endDate
        self.contactIdentifier = event.birthdayContactIdentifier

        self.kind = event.birthdayContactIdentifier != nil ? .birthday : .event
    }

    /// Creates a widget calendar item from an EKReminder, if it has a due date
    init?(from reminder: EKReminder) {
        guard let dueDate = reminder.dueDateComponents?.date else {
            return nil
        }

        self.id = reminder.calendarItemIdentifier
        self.title = reminder.title ?? ""
        self.calendarId = reminder.calendar.calendarIdentifier
        self.color = reminder.calendar.cgColor
        self.isAllDay = false
        self.startDate = dueDate
        self.endDate = reminder.completionDate
        self.contactIdentifier = nil
        self.kind = .reminder
    }

    /// Creates a widget calendar item from any EKCalendarItem
    init?(from item: EKCalendarItem) {
        if let event = item as? EKEvent {
            self = WidgetCalendarItem(from: event)
        } else if let reminder = item as? EKReminder {
            guard let widgetItem = WidgetCalendarItem(from: reminder) else {
                return nil
            }
            self = widgetItem
        } else {
            return nil
        }
    }
}

// MARK: - Date Helpers

extension WidgetCalendarItem {
    func continuesPast(_ date: Date) -> Bool {
        let resetDate = boundStart.zero
        let tomorrow = Calendar.current.date(byAdding: DateComponents(day: 1), to: date)!
        return resetDate < date.zero || (isStartingToday && boundEnd.zero > tomorrow)
    }

    func isSameDay(as other: WidgetCalendarItem) -> Bool {
        let hasSameStartDate = boundStart.zero == other.boundStart.zero
        let hasSameEndDate = boundEnd.zero == other.boundEnd.zero
        return hasSameStartDate || hasSameEndDate
    }

    func isStrictlySameDay(as other: WidgetCalendarItem) -> Bool {
        let hasSameStartDate = boundStart.zero == other.boundStart.zero
        let hasSameEndDate = boundEnd.zero == other.boundEnd.zero
        return hasSameStartDate && hasSameEndDate
    }
}

// MARK: - Collection Extensions

extension Collection<WidgetCalendarItem> {
    func sorted(_ order: ComparisonResult = .orderedAscending) -> [Element] {
        sorted(by: { first, second in
            switch order {
                case .orderedAscending: first < second
                case .orderedDescending: first > second
                case .orderedSame: first == second
            }
        })
    }

    /// Maps items by date, handling items that continue past the reference date
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
}

extension [WidgetCalendarItem] {
    func grouped() -> [[WidgetCalendarItem]] {
        var result = [[WidgetCalendarItem]]()
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

    private func similarElementsWithinSameCalendar(_ item: WidgetCalendarItem) -> [(
        offset: Int,
        element: WidgetCalendarItem
    )] {
        enumerated().compactMap { offset, element in
            guard offset != firstIndex(of: item),
                  element.calendarId == item.calendarId,
                  element.kind == .event,
                  let itemStart = item.startDate,
                  let elementStart = element.startDate,
                  abs(itemStart.timeIntervalSince(elementStart)) < 600 // 10 minutes
            else {
                return nil
            }
            return (offset, element)
        }
    }
}

extension [Date: [WidgetCalendarItem]] {
    func filter(where predicate: @escaping (WidgetCalendarItem) -> Bool) -> Self {
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

    mutating func append(to date: Date, _ item: WidgetCalendarItem) {
        if var list = self[date] {
            list.insert(
                item,
                at: list.firstIndex { $0.boundStart >= item.boundStart } ?? list.endIndex
            )
            updateValue(list, forKey: date)
        } else {
            self[date] = [item]
        }
    }
}
