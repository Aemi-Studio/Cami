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
    private var context: DataContext { .shared }

    private var reminderFilters: [Filters] = [.dueToday]
    private var eventFilters: [Filters] = [.happensToday]

    private(set) var events: [EKEvent] = []
    private(set) var reminders: [EKReminder] = []
    private(set) var overdueReminders: [EKReminder] = []
    private(set) var openReminders: [EKReminder] = []

    var filteredEvents: [EKEvent] {
        events.filter(Filters.any(of: eventFilters).filter)
    }

    var filteredReminders: [EKReminder] {
        reminders.filter(Filters.any(of: reminderFilters).filter)
    }

    private(set) var combinedItems: [EKCalendarItem] = []

    private var cancellables: Set<AnyCancellable> = []

    init(for date: Date) {
        self.date = date
        subscribe()

        Task { @MainActor [weak self] in
            guard let self else {
                return
            }
            await update()
        }
    }

    deinit {
        cancellables.forEach { $0.cancel() }
    }

    private func subscribe() {
        context.publishEventStoreChanges()
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    guard let self else {
                        return
                    }
                    await update()
                }
            }
            .store(in: &cancellables)
    }

    private func getEvents() -> [EKEvent] {
        context.events(during: 1, relativeTo: .now)
    }

    private func getReminders() async -> [EKReminder] {
        await context.reminders(where: Filters.any(of: [Filters.dueToday, Filters.open]).filter)
    }

    private func getOverdueReminders() async -> [EKReminder] {
        await context.reminders(where: Filters.overdue.callable)
    }

    private func getOpenReminders() async -> [EKReminder] {
        await context.reminders(where: Filters.open.callable)
    }

    func update() async {
        events = getEvents()
        reminders = await getReminders()
        overdueReminders = await getOverdueReminders()
        openReminders = await getOpenReminders()
        updateItems()
    }

    private func sort(reminders: [EKReminder]) -> [EKReminder] {
        reminders.sorted {
            guard let lhsDueDate = $0.dueDateComponents?.date,
                  let rhsDueDate = $1.dueDateComponents?.date
            else {
                return false
            }
            return lhsDueDate < rhsDueDate
        }
    }

    private func sort(events: [EKEvent]) -> [EKEvent] {
        events.sorted { $0.startDate < $1.startDate }
    }

    private func merge(events: [EKEvent], reminders: [EKReminder]) -> [EKCalendarItem] {
        var events = events
        var reminders = reminders
        var items = [EKCalendarItem]()

        func sortedInsert(event: EKEvent, reminder: EKReminder) {
            if let dueDate = reminder.dueDateComponents?.date,
               let startDate = event.startDate
            {
                if dueDate < startDate {
                    items.append(reminders.removeFirst())
                } else if dueDate == startDate {
                    if reminder.title < event.title {
                        items.append(reminders.removeFirst())
                    } else {
                        items.append(events.removeFirst())
                    }
                } else {
                    items.append(events.removeFirst())
                }
            }
        }

        for _ in 0 ..< (reminders.count + events.count) {
            if let event = events.first, let reminder = reminders.first {
                sortedInsert(event: event, reminder: reminder)
            } else if !reminders.isEmpty {
                items.append(reminders.removeFirst())
            } else if !events.isEmpty {
                items.append(events.removeFirst())
            }
        }

        return items
    }

    func updateItems() {
        let items = merge(
            events: sort(events: filteredEvents),
            reminders: sort(reminders: filteredReminders)
        )
        if combinedItems != items {
            combinedItems = items
        }
    }
}
