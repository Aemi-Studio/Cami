//
//  WidgetCalendarItem.swift
//  Cami
//
//  Created by Guillaume Coquard on 28/09/25.
//

import Foundation

struct WidgetCalendarItem {
    let id: String
    let kind: Kind
    let title: String
    let calendarId: String
    let colorIndex: UInt8

    let isAllDay: Bool
    let startDate: Date?
    let endDate: Date?

    enum Kind: UInt8, CaseIterable {
        case event = 0
        case reminder = 1
        case birthday = 2
        case streak = 3
    }

    var boundStart: Date {
        startDate ?? endDate ?? .distantPast
    }

    var isStartingToday: Bool {
        boundStart.isToday
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

extension WidgetCalendarItem {
    init?(from calendarItem: CalendarItem) {
        self.id = calendarItem.id
        self.title = calendarItem.title
        self.calendarId = calendarItem.calendar
        self.isAllDay = calendarItem.isAllDay
        self.startDate = calendarItem.start
        self.endDate = calendarItem.end

        self.kind =
            switch calendarItem.kind {
                case .event:
                    if calendarItem.contactIdentifier != nil {
                        .birthday
                    } else {
                        .event
                    }
                case .reminder:
                    .reminder
                case .streak:
                    .streak
            }

        let colorComponents = calendarItem.color?.components ?? [0, 0, 0, 1]
        let red = UInt8(colorComponents[0] * 255)
        let green = UInt8(colorComponents[1] * 255)
        let blue = UInt8(colorComponents[2] * 255)
        self.colorIndex = UInt8((red &+ green &+ blue) / 3)
    }
}

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

    func mappedToDate(relativeTo _: Date) -> [Date: [Element]] {
        var itemsDictionary = [Date: [Element]]()
        let calendar = Calendar.current

        for item in self {
            let itemDate = calendar.startOfDay(for: item.boundStart)
            itemsDictionary[itemDate, default: []].append(item)
        }

        return itemsDictionary.mapValues { items in
            items.sorted()
        }
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
            if !items.isEmpty {
                result[date] = items.sorted()
            }
        }
        return result
    }
}
