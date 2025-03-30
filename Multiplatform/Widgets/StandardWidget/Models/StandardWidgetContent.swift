import Foundation
import SwiftUI
import EventKit

@Observable
final class StandardWidgetContent: Loggable {
    typealias Calendar = String
    typealias Entry = StandardWidgetEntry
    typealias Configuration = StandardWidgetConfiguration
    typealias Filter = (EKCalendarItem) -> Bool

    private static let filter: Filter = Filters.all(of: [Filters.due(), Filters.dueLater, Filters.open]).filter

    let date: Date
    let configuration: Configuration

    private let allCalendars: any Collection<Calendar>
    private let inlineCalendars: any Collection<Calendar>
    private let normalCalendars: any Collection<Calendar>

    private var allItems: [Date: [CalendarItem]] = [:]

    let birthdays: [CalendarItem]

    var items: [Date: [CalendarItem]] {
        allItems.filter(where: {
            if $0.kind == .event {
                self.normalCalendars.contains($0.calendar)
            } else {
                true
            }
        })
    }

    var inlineEvents: [Date: [CalendarItem]] {
        allItems.filter(where: {
            if $0.kind == .event {
                $0.isAllDay && self.inlineCalendars.contains($0.calendar)
            } else {
                false
            }
        })
    }

    private static func birthdays(relativeTo date: Date, with configuration: Configuration) -> [CalendarItem] {
        if configuration.complication == .birthdays {
            DataContext.shared.birthdays(from: date).compactMap(CalendarItem.init)
        } else {
            []
        }
    }

    private static func reminders(
        with configuration: Configuration,
        operation: @escaping ([CalendarItem]) -> Void
    ) {
        if configuration.showReminders {
            DataContext.shared.reminders(where: Self.filter) { reminders in
                operation(reminders.compactMap(CalendarItem.init))
            }
        } else {
            operation([])
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
        let events: [EKEvent] = DataContext.shared.events(
            from: all.asEKCalendars(),
            limit: 20,
            where: { event in
                if let calendarIdentifier = event.calendar?.calendarIdentifier {
                    event.isAllDay && inline.contains(calendarIdentifier) || normal.contains(calendarIdentifier)
                } else {
                    false
                }
            },
            relativeTo: entry.date
        )
        return events.compactMap(CalendarItem.init)
    }

    init(from entry: Entry) {
        self.date = entry.date
        self.configuration = entry.configuration

        self.birthdays = Self.birthdays(relativeTo: entry.date, with: entry.configuration)

        let calendars = Self.calendars(from: entry)

        self.normalCalendars = calendars.normal
        self.inlineCalendars = calendars.inline
        self.allCalendars = calendars.all

        allItems = Self.events(from: entry).mapped(relativeTo: entry.date)

        Self.reminders(with: entry.configuration) { reminders in
            self.allItems += reminders.mapped(relativeTo: entry.date)
        }
    }
}

extension StandardWidgetContent: Equatable {
    static func == (lhs: StandardWidgetContent, rhs: StandardWidgetContent) -> Bool {
        lhs.items == rhs.items && lhs.inlineEvents == rhs.inlineEvents && lhs.birthdays == rhs.birthdays
    }
}
