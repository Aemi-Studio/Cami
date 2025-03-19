import Foundation
import SwiftUI
import EventKit

struct StandardWidgetContent: Loggable {
    typealias Calendar = String
    typealias Entry = StandardWidgetEntry
    typealias Configuration = StandardWidgetConfiguration
    typealias Filter = (EKCalendarItem) -> Bool

    private static let filter: Filter = Filters.all(of: [Filters.due(), Filters.dueLater, Filters.open]).filter

    let date: Date
    let configuration: Configuration

    private let allCalendars: [Calendar]
    private let inlineCalendars: [Calendar]
    private let normalCalendars: [Calendar]

    private let allItems: [Date: [CalendarItem]]

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

    private static func reminders(with configuration: Configuration) -> [CalendarItem] {
        if configuration.showReminders {
            DataContext.shared.reminders(where: Self.filter).compactMap(CalendarItem.init)
        } else {
            []
        }
    }

    typealias Calendars = (normal: [Calendar], inline: [Calendar], all: [Calendar])

    private static func calendars(from entry: Entry) -> Calendars {
        let normal = Set(entry.calendars)
        let inline = Set(entry.inlineCalendars)
        let all = normal.union(inline).sorted()
        return (Array(normal), Array(inline), all)
    }

    private static func events(from entry: Entry) -> [CalendarItem] {
        let (normal, inline, calendars) = Self.calendars(from: entry)
        let events: [EKEvent] = DataContext.shared.events(
            from: calendars.asEKCalendars(),
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

        let (normal, inline, all) = Self.calendars(from: entry)

        self.normalCalendars = normal
        self.inlineCalendars = inline
        self.allCalendars = all

        self.allItems = (Self.reminders(with: entry.configuration) + Self.events(from: entry))
            .sorted()
            .mapped(relativeTo: entry.date)
    }
}

extension StandardWidgetContent: Equatable {
    static func == (lhs: StandardWidgetContent, rhs: StandardWidgetContent) -> Bool {
        lhs.items == rhs.items && lhs.inlineEvents == rhs.inlineEvents && lhs.birthdays == rhs.birthdays
    }
}
