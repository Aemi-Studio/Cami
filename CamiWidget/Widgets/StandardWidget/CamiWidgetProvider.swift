import EventKit
import Foundation
import WidgetKit

struct StandardWidgetEntry: TimelineEntry {
    let date: Date
    let configuration: WidgetConfigurationData
    let sections: [WidgetDaySection]
    let birthdayCount: Int
}

struct WidgetConfigurationData: Sendable {
    let complication: ComplicationEnum
    let allDayStyle: AllDayStyleEnum
    let showReminders: Bool
    let reminderDisplayMode: ReminderDisplayModeEnum
    let useUnifiedList: Bool
    let showHeader: Bool
    let showOngoingEvents: Bool
    let groupEvents: Bool
}

struct WidgetDaySection: Identifiable {
    let id: Date
    let date: Date
    let items: [WidgetTimelineItem]
    let inlineAllDayCount: Int
}

struct WidgetTimelineItem: Identifiable, Hashable {
    enum Kind: UInt8 {
        case event
        case reminder
        case birthday
    }

    let id: String
    let kind: Kind
    let title: String
    let startDate: Date
    let endDate: Date?
    let isAllDay: Bool
    let calendarID: String
    let colorHex: String
    let groupCount: Int

    var displayTitle: String {
        guard groupCount > 1 else {
            return title
        }
        return "\(title) +\(groupCount - 1)"
    }
}

struct CamiWidgetProvider: AppIntentTimelineProvider {
    typealias Entry = StandardWidgetEntry
    typealias Intent = CamiWidgetIntent

    func placeholder(in _: Context) -> Entry {
        StandardWidgetEntry(
            date: .now,
            configuration: WidgetConfigurationData(
                complication: .birthdays,
                allDayStyle: .event,
                showReminders: true,
                reminderDisplayMode: .todayAndOverdue,
                useUnifiedList: true,
                showHeader: true,
                showOngoingEvents: true,
                groupEvents: true
            ),
            sections: [
                WidgetDaySection(
                    id: Calendar.current.startOfDay(for: .now),
                    date: Calendar.current.startOfDay(for: .now),
                    items: [
                        WidgetTimelineItem(
                            id: "placeholder-event",
                            kind: .event,
                            title: "Design review",
                            startDate: .now,
                            endDate: .now.addingTimeInterval(3600),
                            isAllDay: false,
                            calendarID: "placeholder",
                            colorHex: "#1E88E5",
                            groupCount: 1
                        )
                    ],
                    inlineAllDayCount: 1
                )
            ],
            birthdayCount: 1
        )
    }

    func snapshot(for intent: Intent, in _: Context) async -> Entry {
        await createEntry(for: intent, at: .now)
    }

    func timeline(for intent: Intent, in _: Context) async -> Timeline<Entry> {
        let now = Date.now
        let entry = await createEntry(for: intent, at: now)
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: now) ?? now.addingTimeInterval(900)
        return Timeline(entries: [entry], policy: .after(refreshDate))
    }

    private func createEntry(for intent: Intent, at date: Date) async -> Entry {
        let config = WidgetConfigurationData(
            complication: intent.complication,
            allDayStyle: intent.allDayStyle,
            showReminders: intent.reminders,
            reminderDisplayMode: intent.reminderDisplayMode,
            useUnifiedList: intent.useUnifiedList,
            showHeader: intent.showHeader,
            showOngoingEvents: intent.ongoingEvents,
            groupEvents: intent.groupEvents
        )

        let selectedEventCalendarIDs = Set(intent.calendars.map(\.calendarIdentifier))
        let selectedInlineCalendarIDs = Set(intent.inlineCalendars.map(\.calendarIdentifier))

        let repository = WidgetTimelineRepository()
        let snapshot = await repository.snapshot(
            selectedEventCalendarIDs: selectedEventCalendarIDs,
            selectedInlineCalendarIDs: selectedInlineCalendarIDs,
            referenceDate: date,
            configuration: config
        )

        return StandardWidgetEntry(
            date: date,
            configuration: config,
            sections: snapshot.sections,
            birthdayCount: snapshot.birthdayCount
        )
    }
}

private actor WidgetTimelineRepository {
    private let store = EKEventStore()

    struct Snapshot {
        let sections: [WidgetDaySection]
        let birthdayCount: Int
    }

    func snapshot(
        selectedEventCalendarIDs: Set<String>,
        selectedInlineCalendarIDs: Set<String>,
        referenceDate: Date,
        configuration: WidgetConfigurationData
    ) async -> Snapshot {
        let dayStart = Calendar.current.startOfDay(for: referenceDate)
        let dayBefore = Calendar.current.date(byAdding: .day, value: -1, to: dayStart) ?? dayStart
        let rangeEnd = Calendar.current.date(byAdding: .day, value: 7, to: dayStart) ?? dayStart

        let allEventCalendars = store.calendars(for: .event)
        let eventCalendars = allEventCalendars.filter { calendar in
            selectedEventCalendarIDs.isEmpty || selectedEventCalendarIDs.contains(calendar.calendarIdentifier)
        }

        let eventsPredicate = store.predicateForEvents(withStart: dayBefore, end: rangeEnd, calendars: eventCalendars)
        let rawEvents = store.events(matching: eventsPredicate)

        var items: [WidgetTimelineItem] = rawEvents.compactMap { event in
            guard let identifier = event.eventIdentifier else {
                return nil
            }

            let calendarID = event.calendar.calendarIdentifier
            let isBirthday = event.birthdayContactIdentifier != nil
            let kind: WidgetTimelineItem.Kind = isBirthday ? .birthday : .event

            return WidgetTimelineItem(
                id: identifier,
                kind: kind,
                title: event.title ?? String(localized: "Untitled Event"),
                startDate: event.startDate,
                endDate: event.endDate,
                isAllDay: event.isAllDay,
                calendarID: calendarID,
                colorHex: event.calendar.hexColor,
                groupCount: 1
            )
        }

        if configuration.showReminders {
            let reminderCalendars = store.calendars(for: .reminder)
            let remindersPredicate = store.predicateForReminders(in: reminderCalendars)
            let reminders = await withCheckedContinuation { continuation in
                store.fetchReminders(matching: remindersPredicate) { result in
                    continuation.resume(returning: result ?? [])
                }
            }

            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart

            let reminderItems = reminders
                .filter { !$0.isCompleted }
                .compactMap { reminder -> WidgetTimelineItem? in
                    guard let dueDate = reminder.dueDateComponents?.date else {
                        return nil
                    }

                    let shouldInclude: Bool
                    switch configuration.reminderDisplayMode {
                    case .todayOnly:
                        shouldInclude = dueDate >= dayStart && dueDate < tomorrow
                    case .todayAndOverdue:
                        shouldInclude = dueDate < tomorrow
                    case .upcoming:
                        shouldInclude = true
                    }

                    guard shouldInclude else {
                        return nil
                    }

                    return WidgetTimelineItem(
                        id: reminder.calendarItemIdentifier,
                        kind: .reminder,
                        title: reminder.title ?? String(localized: "Untitled Reminder"),
                        startDate: dueDate,
                        endDate: nil,
                        isAllDay: false,
                        calendarID: reminder.calendar.calendarIdentifier,
                        colorHex: reminder.calendar.hexColor,
                        groupCount: 1
                    )
                }

            items.append(contentsOf: reminderItems)
        }

        if configuration.allDayStyle == .hidden {
            items = items.filter { item in
                guard item.kind == .event || item.kind == .birthday else {
                    return true
                }
                guard item.isAllDay else {
                    return true
                }
                return configuration.showOngoingEvents && item.startDate < dayStart
            }
        }

        if !configuration.showOngoingEvents {
            items = items.filter { item in
                Calendar.current.startOfDay(for: item.startDate) >= dayStart
            }
        }

        let birthdayCount = items.filter { $0.kind == .birthday }.count

        let grouped: [WidgetTimelineItem]
        if configuration.groupEvents {
            grouped = groupSimilarEvents(items)
        } else {
            grouped = items
        }

        let sections = buildSections(
            grouped,
            inlineCalendarIDs: selectedInlineCalendarIDs,
            useUnifiedList: configuration.useUnifiedList,
            showReminders: configuration.showReminders
        )

        return Snapshot(sections: sections, birthdayCount: birthdayCount)
    }

    private func buildSections(
        _ items: [WidgetTimelineItem],
        inlineCalendarIDs: Set<String>,
        useUnifiedList: Bool,
        showReminders: Bool
    ) -> [WidgetDaySection] {
        var buckets: [Date: [WidgetTimelineItem]] = [:]
        var inlineCounts: [Date: Int] = [:]

        for item in items {
            let day = Calendar.current.startOfDay(for: item.startDate)

            if item.isAllDay && inlineCalendarIDs.contains(item.calendarID) {
                inlineCounts[day, default: 0] += 1
            }

            buckets[day, default: []].append(item)
        }

        return buckets.keys.sorted().map { day in
            let dayItems = (buckets[day] ?? [])
                .sorted { lhs, rhs in
                    if lhs.startDate != rhs.startDate {
                        return lhs.startDate < rhs.startDate
                    }
                    return lhs.title < rhs.title
                }

            let ordered: [WidgetTimelineItem]
            if showReminders && !useUnifiedList {
                let reminders = dayItems.filter { $0.kind == .reminder }
                let nonReminders = dayItems.filter { $0.kind != .reminder }
                ordered = reminders + nonReminders
            } else {
                ordered = dayItems
            }

            return WidgetDaySection(
                id: day,
                date: day,
                items: ordered,
                inlineAllDayCount: inlineCounts[day, default: 0]
            )
        }
    }

    private func groupSimilarEvents(_ items: [WidgetTimelineItem]) -> [WidgetTimelineItem] {
        let sorted = items.sorted { $0.startDate < $1.startDate }
        var consumed = Set<String>()
        var result: [WidgetTimelineItem] = []

        for item in sorted where !consumed.contains(item.id) {
            guard item.kind == .event else {
                consumed.insert(item.id)
                result.append(item)
                continue
            }

            let group = sorted.filter { candidate in
                !consumed.contains(candidate.id)
                    && candidate.kind == .event
                    && candidate.calendarID == item.calendarID
                    && abs(candidate.startDate.timeIntervalSince(item.startDate)) < 600
            }

            group.forEach { consumed.insert($0.id) }

            if group.count <= 1 {
                result.append(item)
            } else {
                result.append(
                    WidgetTimelineItem(
                        id: item.id,
                        kind: item.kind,
                        title: item.title,
                        startDate: item.startDate,
                        endDate: item.endDate,
                        isAllDay: item.isAllDay,
                        calendarID: item.calendarID,
                        colorHex: item.colorHex,
                        groupCount: group.count
                    )
                )
            }
        }

        return result
    }
}

private extension EKCalendar {
    var hexColor: String {
        guard let components = cgColor.components else {
            return "#6D6D6D"
        }

        let red = Int((components[safe: 0] ?? 0.43) * 255)
        let green = Int((components[safe: 1] ?? 0.43) * 255)
        let blue = Int((components[safe: 2] ?? 0.43) * 255)

        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else {
            return nil
        }
        return self[index]
    }
}
