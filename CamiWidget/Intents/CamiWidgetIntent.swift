import AppIntents
import EventKit
import Foundation
import WidgetKit

enum ComplicationEnum: String, CaseIterable, AppEnum {
    case hidden = "Hidden"
    case birthdays = "Birthdays"
    case summary = "Summary"

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Complication"
    static let caseDisplayRepresentations: [ComplicationEnum: DisplayRepresentation] = [
        .hidden: "Hidden",
        .birthdays: "Birthdays",
        .summary: "Summary"
    ]
}

enum AllDayStyleEnum: String, CaseIterable, AppEnum {
    case hidden = "Hidden"
    case event = "Event"
    case bordered = "Event Bordered"

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "All-Day Style"
    static let caseDisplayRepresentations: [AllDayStyleEnum: DisplayRepresentation] = [
        .hidden: "Hidden",
        .event: "Event",
        .bordered: "Event Bordered"
    ]
}

enum ReminderDisplayModeEnum: String, CaseIterable, AppEnum {
    case todayOnly = "Today Only"
    case todayAndOverdue = "Today & Overdue"
    case upcoming = "Upcoming"

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Reminder Display"
    static let caseDisplayRepresentations: [ReminderDisplayModeEnum: DisplayRepresentation] = [
        .todayOnly: "Today Only",
        .todayAndOverdue: "Today & Overdue",
        .upcoming: "Upcoming"
    ]
}

struct WidgetCalendarEntity: AppEntity {
    let id: String
    let calendarIdentifier: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Calendar"
    static var defaultQuery = WidgetCalendarQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(id)")
    }
}

struct WidgetCalendarQuery: EntityQuery {
    func entities(for identifiers: [WidgetCalendarEntity.ID]) async throws -> [WidgetCalendarEntity] {
        let all = await fetchCalendars()
        return all.filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [WidgetCalendarEntity] {
        await fetchCalendars()
    }

    func defaultResult() async -> [WidgetCalendarEntity] {
        await fetchCalendars()
    }

    @MainActor
    private func fetchCalendars() -> [WidgetCalendarEntity] {
        let store = EKEventStore()
        return store.calendars(for: .event)
            .map { calendar in
                WidgetCalendarEntity(
                    id: "\(calendar.source.title) - \(calendar.title)",
                    calendarIdentifier: calendar.calendarIdentifier
                )
            }
            .sorted { $0.id < $1.id }
    }
}

struct CamiWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "Cami widget configuration" }

    @Parameter(title: "Complication", default: .birthdays)
    var complication: ComplicationEnum

    @Parameter(title: "Calendars", default: [])
    var calendars: [WidgetCalendarEntity]

    @Parameter(title: "All-Day Inline Calendars", default: [])
    var inlineCalendars: [WidgetCalendarEntity]

    @Parameter(title: "All-Day Events Style", default: .event)
    var allDayStyle: AllDayStyleEnum

    @Parameter(title: "Group Similar Events", default: true)
    var groupEvents: Bool

    @Parameter(title: "Ongoing Events", default: true)
    var ongoingEvents: Bool

    @Parameter(title: "Show Reminders", default: true)
    var reminders: Bool

    @Parameter(title: "Reminder Display Mode", default: .todayAndOverdue)
    var reminderDisplayMode: ReminderDisplayModeEnum

    @Parameter(title: "Mix Events & Reminders", default: true)
    var useUnifiedList: Bool

    @Parameter(title: "Header", default: true)
    var showHeader: Bool
}
