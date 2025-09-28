//
//  LightweightWidgetContent.swift
//  Cami
//
//  Created by Guillaume Coquard on 28/09/25.
//

import EventKit
import Foundation
import SwiftUI

@Observable
final class LightweightWidgetContent: Loggable {
    typealias Calendar = String
    typealias Entry = StandardWidgetEntry
    typealias Configuration = StandardWidgetConfiguration

    private static let widgetDataService = WidgetDataService()

    let date: Date
    let configuration: Configuration

    private let normalCalendars: Set<Calendar>
    private let inlineCalendars: Set<Calendar>

    private var allItems: [Date: [WidgetCalendarItem]] = [:]

    let birthdays: [WidgetCalendarItem]

    var items: [Date: [WidgetCalendarItem]] {
        allItems.filter { [self] item in
            if item.kind == .event {
                normalCalendars.contains(item.calendarId)
            } else {
                true
            }
        }
    }

    var inlineEvents: [Date: [WidgetCalendarItem]] {
        allItems.filter { [self] item in
            if item.kind == .event {
                item.isAllDay && inlineCalendars.contains(item.calendarId)
            } else {
                false
            }
        }
    }

    private static func fetchBirthdays(relativeTo date: Date, configuration: Configuration) -> [WidgetCalendarItem] {
        guard configuration.complication == .birthdays else { return [] }

        return widgetDataService.getBirthdaysForWidget(referenceDate: date)
            .compactMap { event in
                guard let calendarItem = CalendarItem(from: event) else { return nil }
                return WidgetCalendarItem(from: calendarItem)
            }
    }

    private static func fetchReminders(
        configuration: Configuration,
        completion: @escaping ([WidgetCalendarItem]) -> Void
    ) {
        guard configuration.showReminders else {
            completion([])
            return
        }

        widgetDataService.getRemindersForWidget { reminders in
            let items: [WidgetCalendarItem] = reminders.compactMap { reminder in
                guard let calendarItem = CalendarItem(from: reminder) else { return nil }
                return WidgetCalendarItem(from: calendarItem)
            }
            completion(items)
        }
    }

    private static func fetchEvents(from entry: Entry, calendars: (normal: Set<Calendar>, inline: Set<Calendar>)) -> [WidgetCalendarItem] {
        let allCalendars = calendars.normal.union(calendars.inline)

        guard !allCalendars.isEmpty else {
            logger.warning("No calendars available for lightweight widget")
            return []
        }

        return widgetDataService.getEventsForWidget(
            calendars: Array(allCalendars),
            limit: 15,
            referenceDate: entry.date
        ).compactMap { event in
            guard let calendarId = event.calendar?.calendarIdentifier else { return nil }

            let isRelevant = event.isAllDay && calendars.inline.contains(calendarId) ||
                           calendars.normal.contains(calendarId)

            guard isRelevant else { return nil }

            guard let calendarItem = CalendarItem(from: event) else { return nil }
            return WidgetCalendarItem(from: calendarItem)
        }
    }

    init(from entry: Entry) {
        self.date = entry.date
        self.configuration = entry.configuration

        self.normalCalendars = Set(entry.calendars)
        self.inlineCalendars = Set(entry.inlineCalendars)

        self.birthdays = Self.fetchBirthdays(relativeTo: entry.date, configuration: entry.configuration)

        let calendars = (normal: normalCalendars, inline: inlineCalendars)
        let events = Self.fetchEvents(from: entry, calendars: calendars)
        self.allItems = events.mappedToDate(relativeTo: entry.date)

        Self.fetchReminders(configuration: entry.configuration) { [weak self] reminders in
            let reminderDict = reminders.mappedToDate(relativeTo: entry.date)
            self?.allItems = (self?.allItems ?? [:]) + reminderDict
        }
    }
}

extension LightweightWidgetContent: Equatable {
    static func == (lhs: LightweightWidgetContent, rhs: LightweightWidgetContent) -> Bool {
        lhs.items == rhs.items && lhs.inlineEvents == rhs.inlineEvents && lhs.birthdays == rhs.birthdays
    }
}