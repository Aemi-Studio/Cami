import EventKit
import Foundation
import SwiftUI

@Observable
final class StandardWidgetContent: Loggable {
    typealias Calendar = String
    typealias Entry = StandardWidgetEntry
    typealias Configuration = StandardWidgetConfiguration
    private static let widgetDataService = WidgetDataService()

    let date: Date
    let configuration: Configuration

    private let inlineCalendars: any Collection<Calendar>
    private let normalCalendars: any Collection<Calendar>

    private var _allItems: [Date: [CalendarItem]]?
    private var _birthdays: [CalendarItem]?
    private var _items: [Date: [CalendarItem]]?
    private var _inlineEvents: [Date: [CalendarItem]]?

    private let entry: Entry

    private var allItems: [Date: [CalendarItem]] {
        if let _allItems {
            return _allItems
        }

        var items = Self.events(from: entry).mapped(relativeTo: entry.date)

        Self.reminders(with: configuration) { reminders in
            items += reminders.mapped(relativeTo: self.entry.date)
        }

        _allItems = items
        return items
    }

    var birthdays: [CalendarItem] {
        if let _birthdays {
            return _birthdays
        }

        let result = Self.birthdays(relativeTo: entry.date, with: configuration)
        _birthdays = result
        return result
    }

    var items: [Date: [CalendarItem]] {
        if let _items {
            return _items
        }

        let result = allItems.filter(where: {
            if $0.kind == .event {
                self.normalCalendars.contains($0.calendar)
            } else {
                true
            }
        })
        _items = result
        return result
    }

    var inlineEvents: [Date: [CalendarItem]] {
        if let _inlineEvents {
            return _inlineEvents
        }

        let result = allItems.filter(where: {
            if $0.kind == .event {
                $0.isAllDay && self.inlineCalendars.contains($0.calendar)
            } else {
                false
            }
        })
        _inlineEvents = result
        return result
    }

    private static func birthdays(relativeTo date: Date, with configuration: Configuration) -> [CalendarItem] {
        if configuration.complication == .birthdays {
            widgetDataService.getBirthdaysForWidget(referenceDate: date).compactMap(CalendarItem.init)
        } else {
            []
        }
    }

    private static func reminders(
        with configuration: Configuration,
        operation: @escaping ([CalendarItem]) -> Void
    ) {
        guard configuration.showReminders else {
            operation([])
            return
        }

        widgetDataService.getRemindersForWidget { reminders in
            let calendarItems = reminders.compactMap(CalendarItem.init)
            operation(calendarItems)
        }
    }

    private struct Calendars {
        let normal: any Collection<Calendar>
        let inline: any Collection<Calendar>
        let all: any Collection<Calendar>
    }

    private static func calendars(from entry: Entry) -> Calendars {
        let normal = Set(entry.calendars)
        let inline = Set(entry.inlineCalendars)
        let all = normal.union(inline).sorted()
        return Calendars(normal: normal, inline: inline, all: all)
    }

    private static func events(from entry: Entry) -> [CalendarItem] {
        let calendars = Self.calendars(from: entry)
        let normal = calendars.normal
        let inline = calendars.inline
        let all = calendars.all

        guard !all.isEmpty else {
            Self.logger.warning("No calendars available for widget")
            return []
        }

        let events = widgetDataService.getEventsForWidget(
            calendars: Array(all),
            limit: 20,
            referenceDate: entry.date
        ).filter { event in
            guard let calendarIdentifier = event.calendar?.calendarIdentifier else {
                return false
            }
            return event.isAllDay && inline.contains(calendarIdentifier) || normal.contains(calendarIdentifier)
        }

        return events.compactMap(CalendarItem.init)
    }

    init(from entry: Entry) {
        self.entry = entry
        self.date = entry.date
        self.configuration = entry.configuration

        let calendars = Self.calendars(from: entry)

        self.normalCalendars = calendars.normal
        self.inlineCalendars = calendars.inline
    }
}

extension StandardWidgetContent: Equatable {
    static func == (lhs: StandardWidgetContent, rhs: StandardWidgetContent) -> Bool {
        lhs.items == rhs.items && lhs.inlineEvents == rhs.inlineEvents && lhs.birthdays == rhs.birthdays
    }
}
