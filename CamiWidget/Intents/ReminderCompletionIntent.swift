//
//  ReminderCompletionIntent.swift
//  Cami
//
//  Created by Guillaume Coquard on 16/03/25.
//

import AppIntents
import EventKit
import WidgetKit

struct ReminderCompletionIntent: AppIntent {
    init() {}

    @Parameter(title: "Reminder Identifier")
    var reminderIdentifier: String

    init(_ reminderIdentifier: String) {
        self.reminderIdentifier = reminderIdentifier
    }

    static var title: LocalizedStringResource = "Reminder Completion"
    static var description = "Complete this reminder"
    static let openAppWhenRun: Bool = false
    static let isDiscoverable: Bool = false

    func perform() async throws -> some IntentResult {
        if await DataContext.shared.completeReminder(withIdentifier: reminderIdentifier) {
            return .result(value: "Reminder completed")
        } else {
            return .result(value: "Reminder not completed")
        }
    }
}
