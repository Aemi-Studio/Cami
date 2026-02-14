import Foundation

public enum ReminderDisplayMode: String, CaseIterable, Sendable {
    case todayOnly
    case todayAndOverdue
    case upcoming
}

public enum AllDayStyle: String, CaseIterable, Sendable {
    case hidden
    case event
    case bordered
}
