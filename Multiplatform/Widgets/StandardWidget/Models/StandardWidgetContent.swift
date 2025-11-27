import EventKit
import Foundation
import SwiftUI

/// Widget content that holds pre-computed calendar data for synchronous access in widget views.
///
/// Use `StandardWidgetContent.create(from:)` to asynchronously fetch and populate data,
/// then access properties synchronously in widget views.
@Observable
final class StandardWidgetContent: Loggable {
    typealias Calendar = String
    typealias Entry = StandardWidgetEntry
    typealias Configuration = StandardWidgetConfiguration

    let date: Date
    let configuration: Configuration

    /// Pre-computed birthdays for the widget
    let birthdays: [WidgetCalendarItem]

    /// Pre-computed items (events and reminders) grouped by date
    let items: [Date: [WidgetCalendarItem]]

    /// Pre-computed inline (all-day) events grouped by date
    let inlineEvents: [Date: [WidgetCalendarItem]]

    // MARK: - Initialization

    /// Creates a default content instance with empty data.
    /// Use `create(from:)` for populated content.
    init(from entry: Entry) {
        self.date = entry.date
        self.configuration = entry.configuration
        self.birthdays = []
        self.items = [:]
        self.inlineEvents = [:]
    }

    /// Initializer for fully populated content
    init(
        date: Date,
        configuration: Configuration,
        birthdays: [WidgetCalendarItem],
        items: [Date: [WidgetCalendarItem]],
        inlineEvents: [Date: [WidgetCalendarItem]]
    ) {
        self.date = date
        self.configuration = configuration
        self.birthdays = birthdays
        self.items = items
        self.inlineEvents = inlineEvents
    }

    // MARK: - Factory Method

    /// Asynchronously creates widget content by fetching all required data.
    @MainActor
    static func create(from entry: Entry) async -> StandardWidgetContent {
        let widgetDataService = WidgetDataService()
        let calendars = Self.calendars(from: entry)
        let normalCalendars = calendars.normal
        let inlineCalendars = calendars.inline

        // Fetch birthdays
        let birthdays: [WidgetCalendarItem]
        if entry.configuration.complication == .birthdays {
            birthdays = await widgetDataService
                .getBirthdaysForWidget(referenceDate: entry.date)
                .map(WidgetCalendarItem.init)
        } else {
            birthdays = []
        }

        // Fetch events
        let eventItems = await Self.fetchEvents(
            from: entry,
            using: widgetDataService,
            calendars: calendars
        )

        // Fetch reminders
        let reminderItems: [WidgetCalendarItem]
        if entry.configuration.showReminders {
            let reminders = await widgetDataService.getRemindersForWidget()
            reminderItems = reminders.compactMap(WidgetCalendarItem.init)
        } else {
            reminderItems = []
        }

        // Combine and map all items
        var allItems = eventItems.mapped(relativeTo: entry.date)
        allItems += reminderItems.mapped(relativeTo: entry.date)

        // Filter items for normal calendars
        let items = allItems.filter(where: { item in
            if item.kind == .event || item.kind == .birthday {
                normalCalendars.contains(item.calendarId)
            } else {
                true
            }
        })

        // Filter inline events (all-day events from inline calendars)
        let inlineEvents = allItems.filter(where: { item in
            if item.kind == .event || item.kind == .birthday {
                item.isAllDay && inlineCalendars.contains(item.calendarId)
            } else {
                false
            }
        })

        return StandardWidgetContent(
            date: entry.date,
            configuration: entry.configuration,
            birthdays: birthdays,
            items: items,
            inlineEvents: inlineEvents
        )
    }

    // MARK: - Private Helpers

    private struct Calendars {
        let normal: Set<Calendar>
        let inline: Set<Calendar>
        let all: [Calendar]
    }

    private static func calendars(from entry: Entry) -> Calendars {
        let normal = Set(entry.calendars)
        let inline = Set(entry.inlineCalendars)
        let all = normal.union(inline).sorted()
        return Calendars(normal: normal, inline: inline, all: all)
    }

    @MainActor
    private static func fetchEvents(
        from entry: Entry,
        using widgetDataService: WidgetDataService,
        calendars: Calendars
    ) async -> [WidgetCalendarItem] {
        let normal = calendars.normal
        let inline = calendars.inline
        let all = calendars.all

        guard !all.isEmpty else {
            Self.logger.warning("No calendars available for widget")
            return []
        }

        let events = await widgetDataService.getEventsForWidget(
            calendars: Array(all),
            limit: 20,
            referenceDate: entry.date
        ).filter { event in
            guard let calendarIdentifier = event.calendar?.calendarIdentifier else {
                return false
            }
            return event.isAllDay && inline.contains(calendarIdentifier) || normal.contains(calendarIdentifier)
        }

        return events.map(WidgetCalendarItem.init)
    }
}

