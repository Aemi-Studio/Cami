import CamiCore
import Foundation
import Testing

struct CalendarFilterEngineTests {
    private let referenceDate = Date(timeIntervalSinceReferenceDate: 760_000_000) // 2025-ish fixed

    @Test("Today-only reminders include only today")
    func todayOnlyMode() {
        let startOfDay = Calendar.current.startOfDay(for: referenceDate)
        let reminders: [CalendarEntry] = [
            .reminder(id: "y", title: "Yesterday", dueDate: Calendar.current.date(byAdding: .day, value: -1, to: startOfDay)!),
            .reminder(id: "t", title: "Today", dueDate: Calendar.current.date(byAdding: .hour, value: 8, to: startOfDay)!),
            .reminder(id: "m", title: "Tomorrow", dueDate: Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!),
            .reminder(id: "n", title: "NoDue", dueDate: nil)
        ]

        let filtered = CalendarFilterEngine.filterReminders(
            reminders,
            mode: .todayOnly,
            referenceDate: referenceDate
        )

        #expect(filtered.map(\.id) == ["t"])
    }

    @Test("Today+overdue reminders include yesterday and today")
    func todayAndOverdueMode() {
        let startOfDay = Calendar.current.startOfDay(for: referenceDate)
        let reminders: [CalendarEntry] = [
            .reminder(id: "y", title: "Yesterday", dueDate: Calendar.current.date(byAdding: .day, value: -1, to: startOfDay)!),
            .reminder(id: "t", title: "Today", dueDate: Calendar.current.date(byAdding: .hour, value: 8, to: startOfDay)!),
            .reminder(id: "m", title: "Tomorrow", dueDate: Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!)
        ]

        let filtered = CalendarFilterEngine.filterReminders(
            reminders,
            mode: .todayAndOverdue,
            referenceDate: referenceDate
        )

        #expect(filtered.map(\.id) == ["y", "t"])
    }

    @Test("Upcoming reminders include all due-dated reminders")
    func upcomingMode() {
        let startOfDay = Calendar.current.startOfDay(for: referenceDate)
        let reminders: [CalendarEntry] = [
            .reminder(id: "y", title: "Yesterday", dueDate: Calendar.current.date(byAdding: .day, value: -1, to: startOfDay)!),
            .reminder(id: "t", title: "Today", dueDate: Calendar.current.date(byAdding: .hour, value: 8, to: startOfDay)!),
            .reminder(id: "m", title: "Tomorrow", dueDate: Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!),
            .reminder(id: "n", title: "NoDue", dueDate: nil)
        ]

        let filtered = CalendarFilterEngine.filterReminders(
            reminders,
            mode: .upcoming,
            referenceDate: referenceDate
        )

        #expect(filtered.map(\.id) == ["y", "t", "m"])
    }

    @Test("Groups similar events by calendar within ten minutes")
    func groupsSimilarEvents() {
        let base = referenceDate
        let events: [CalendarEntry] = [
            .event(id: "a", title: "A", calendarID: "cal-1", startDate: base, endDate: base.addingTimeInterval(1800), isAllDay: false),
            .event(id: "b", title: "B", calendarID: "cal-1", startDate: base.addingTimeInterval(420), endDate: base.addingTimeInterval(3600), isAllDay: false),
            .event(id: "c", title: "C", calendarID: "cal-2", startDate: base.addingTimeInterval(300), endDate: base.addingTimeInterval(3600), isAllDay: false)
        ]

        let groups = CalendarFilterEngine.groupSimilarEvents(events)
        #expect(groups.count == 2)
        #expect(groups.first?.map(\.id) == ["a", "b"])
    }

    @Test("Hidden all-day style excludes non-ongoing all-day events")
    func hiddenAllDayStyle() {
        let startOfDay = Calendar.current.startOfDay(for: referenceDate)
        let entries: [CalendarEntry] = [
            .event(id: "all-day", title: "All Day", calendarID: "cal-1", startDate: startOfDay, endDate: startOfDay.addingTimeInterval(3600), isAllDay: true),
            .event(id: "timed", title: "Timed", calendarID: "cal-1", startDate: startOfDay.addingTimeInterval(7200), endDate: startOfDay.addingTimeInterval(9000), isAllDay: false)
        ]

        let filtered = CalendarFilterEngine.filterAllDay(
            entries,
            style: .hidden,
            showOngoingEvents: false,
            referenceDate: referenceDate
        )

        #expect(filtered.map(\.id) == ["timed"])
    }
}
