//
//  SingleDayContext.swift
//  Cami
//
//  Created by Guillaume Coquard on 16/03/25.
//

import Combine
import EventKit
import SwiftUI

@Observable
final class SingleDayContext {
    let date: Date
    let context: DataContext

    private(set) var events: [EKEvent] = []
    private(set) var reminders: [EKReminder] = []
    private(set) var overdueReminders: [EKReminder] = []
    private(set) var openReminders: [EKReminder] = []

    private var cancellables: Set<AnyCancellable> = []

    init(for date: Date, in context: DataContext) {
        self.date = date
        self.context = context
        update()
        subscribe()
    }

    func subscribe() {
        context.publishEventStoreChanges()
            .sink { [weak self] _ in self?.update() }
            .store(in: &cancellables)
    }

    func getEvents() -> [EKEvent] {
        context.events(during: 1, relativeTo: .now)
    }

    func getReminders() -> [EKReminder] {
        context.reminders(where: Filters.any(of: [Filters.dueToday, Filters.open]).filter)
    }

    func getOverdueReminders() -> [EKReminder] {
        context.reminders(where: Filters.overdue.callable)
    }

    func getOpenReminders() -> [EKReminder] {
        context.reminders(where: Filters.open.callable)
    }

    func update() {
        events = getEvents()
        reminders = getReminders()
        overdueReminders = getOverdueReminders()
        openReminders = getOpenReminders()
    }
}
