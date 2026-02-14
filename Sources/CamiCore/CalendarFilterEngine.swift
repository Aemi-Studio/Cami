import Foundation

public enum CalendarFilterEngine {
    public static func filterReminders(
        _ entries: [CalendarEntry],
        mode: ReminderDisplayMode,
        referenceDate: Date
    ) -> [CalendarEntry] {
        let dayStart = Calendar.current.startOfDay(for: referenceDate)
        let tomorrowStart = Calendar.current.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart

        return entries
            .filter { $0.kind == .reminder }
            .filter { !$0.isCompleted }
            .filter { $0.startDate != nil }
            .filter { reminder in
                guard let dueDate = reminder.startDate else {
                    return false
                }

                switch mode {
                case .todayOnly:
                    return dueDate >= dayStart && dueDate < tomorrowStart
                case .todayAndOverdue:
                    return dueDate < tomorrowStart
                case .upcoming:
                    return true
                }
            }
            .sorted { lhs, rhs in
                lhs.boundStart < rhs.boundStart
            }
    }

    public static func groupSimilarEvents(_ entries: [CalendarEntry]) -> [[CalendarEntry]] {
        let events = entries
            .filter { $0.kind == .event }
            .sorted { lhs, rhs in
                if lhs.boundStart != rhs.boundStart {
                    return lhs.boundStart < rhs.boundStart
                }
                return lhs.title < rhs.title
            }

        var groups: [[CalendarEntry]] = []
        var consumed = Set<String>()

        for entry in events where !consumed.contains(entry.id) {
            let seedStart = entry.boundStart
            let group = events.filter { candidate in
                !consumed.contains(candidate.id)
                    && candidate.calendarID == entry.calendarID
                    && abs(candidate.boundStart.timeIntervalSince(seedStart)) < 600
            }

            for candidate in group {
                consumed.insert(candidate.id)
            }

            groups.append(group)
        }

        return groups
    }

    public static func filterAllDay(
        _ entries: [CalendarEntry],
        style: AllDayStyle,
        showOngoingEvents: Bool,
        referenceDate: Date
    ) -> [CalendarEntry] {
        guard style == .hidden else {
            return entries
        }

        return entries.filter { entry in
            guard entry.kind == .event || entry.kind == .birthday else {
                return true
            }

            if !entry.isAllDay {
                return true
            }

            return showOngoingEvents && entry.continuesPast(referenceDate)
        }
    }
}

private extension CalendarEntry {
    func continuesPast(_ date: Date) -> Bool {
        let startOfEntryDay = Calendar.current.startOfDay(for: boundStart)
        let startOfReferenceDay = Calendar.current.startOfDay(for: date)
        let startOfTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: startOfReferenceDay) ?? startOfReferenceDay

        let startsToday = startOfEntryDay == startOfReferenceDay
        let endDay = Calendar.current.startOfDay(for: boundEnd)

        return startOfEntryDay < startOfReferenceDay || (startsToday && endDay >= startOfTomorrow)
    }
}
