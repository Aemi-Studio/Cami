import Foundation

public enum CalendarEntryKind: UInt8, Sendable, Hashable {
    case event
    case reminder
    case birthday
}

public struct CalendarEntry: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let kind: CalendarEntryKind
    public let calendarID: String
    public let startDate: Date?
    public let endDate: Date?
    public let isAllDay: Bool
    public let isCompleted: Bool

    public init(
        id: String,
        title: String,
        kind: CalendarEntryKind,
        calendarID: String,
        startDate: Date?,
        endDate: Date?,
        isAllDay: Bool,
        isCompleted: Bool
    ) {
        self.id = id
        self.title = title
        self.kind = kind
        self.calendarID = calendarID
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.isCompleted = isCompleted
    }
}

public extension CalendarEntry {
    static func event(
        id: String,
        title: String,
        calendarID: String,
        startDate: Date,
        endDate: Date,
        isAllDay: Bool
    ) -> Self {
        Self(
            id: id,
            title: title,
            kind: .event,
            calendarID: calendarID,
            startDate: startDate,
            endDate: endDate,
            isAllDay: isAllDay,
            isCompleted: false
        )
    }

    static func birthday(
        id: String,
        title: String,
        calendarID: String,
        startDate: Date,
        endDate: Date,
        isAllDay: Bool = true
    ) -> Self {
        Self(
            id: id,
            title: title,
            kind: .birthday,
            calendarID: calendarID,
            startDate: startDate,
            endDate: endDate,
            isAllDay: isAllDay,
            isCompleted: false
        )
    }

    static func reminder(
        id: String,
        title: String,
        dueDate: Date?,
        calendarID: String = "default",
        isCompleted: Bool = false
    ) -> Self {
        Self(
            id: id,
            title: title,
            kind: .reminder,
            calendarID: calendarID,
            startDate: dueDate,
            endDate: nil,
            isAllDay: false,
            isCompleted: isCompleted
        )
    }
}

public extension CalendarEntry {
    var boundStart: Date {
        startDate ?? endDate ?? .distantPast
    }

    var boundEnd: Date {
        endDate ?? startDate ?? .distantFuture
    }
}
