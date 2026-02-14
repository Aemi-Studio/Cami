import AppIntents
import EventKit
import WidgetKit

struct ReminderCompletionIntent: AppIntent {
    static var title: LocalizedStringResource = "Complete Reminder"
    static var description = IntentDescription("Marks a reminder as completed from the widget.")
    static let openAppWhenRun = false
    static let isDiscoverable = false

    @Parameter(title: "Reminder Identifier")
    var reminderIdentifier: String

    init() {
        reminderIdentifier = ""
    }

    init(_ reminderIdentifier: String) {
        self.reminderIdentifier = reminderIdentifier
    }

    func perform() async throws -> some IntentResult {
        let success = await ReminderCompletionService.shared.complete(reminderIdentifier: reminderIdentifier)
        WidgetCenter.shared.reloadAllTimelines()

        if success {
            return .result(dialog: IntentDialog("Reminder completed."))
        }
        return .result(dialog: IntentDialog("Reminder could not be completed."))
    }
}

actor ReminderCompletionService {
    static let shared = ReminderCompletionService()

    private let store = EKEventStore()

    func complete(reminderIdentifier: String) async -> Bool {
        let predicate = store.predicateForReminders(in: store.calendars(for: .reminder))
        let reminders = await withCheckedContinuation { continuation in
            store.fetchReminders(matching: predicate) { reminders in
                continuation.resume(returning: reminders ?? [])
            }
        }

        guard let reminder = reminders.first(where: { $0.calendarItemIdentifier == reminderIdentifier }) else {
            return false
        }

        do {
            reminder.isCompleted = true
            try store.save(reminder, commit: true)
            return true
        } catch {
            return false
        }
    }
}
