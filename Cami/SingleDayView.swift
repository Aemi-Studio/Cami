//
//  CustomDayView.swift
//  Cami
//
//  Created by Guillaume Coquard on 23/01/25.
//

import Combine
import SwiftUI
import EventKit

@Observable
final class SingleDayContext {

    let date: Date
    let context: DataContext

    private(set) var events: CItems = []
    private(set) var reminders: CItems = []
    private(set) var overdueReminders: Reminders = []
    private(set) var openReminders: Reminders = []

    private var cancellables: Set<AnyCancellable> = []

    init(for date: Date, in context: DataContext) {
        self.date = date
        self.context = context
        self.update()
        self.subscribe()
    }

    func subscribe() {
        context.publishEventStoreChanges()
            .sink { [weak self] _ in self?.update() }
            .store(in: &cancellables)
    }

    func getEvents() -> CItems {
        context.events(relativeTo: .now)
    }

    func getReminders() -> Reminders {
        context.reminders(where: Filters.any(of: [Filters.dueToday, Filters.open]).filter)
    }

    func getOverdueReminders() -> Reminders {
        context.reminders(where: Filters.overdue.callable)
    }

    func getOpenReminders() -> Reminders {
        context.reminders(where: Filters.open.callable)
    }

    func update() {
        self.events = getEvents()
        self.reminders = getReminders()
        self.overdueReminders = getOverdueReminders()
        self.openReminders = getOpenReminders()
    }
}

struct SingleDayView: View {

    @State private var reminderFilters: [Filters] = [
        .dueToday,
        .open,
        .overdue
    ]

    @State private var eventFilters: [Filters] = [
        .happensToday
    ]

    private let date: Date
    private let context: SingleDayContext

    init(date: Date) {
        self.date = date
        self.context = SingleDayContext(
            for: date,
            in: DataContext.shared
        )
    }

    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                LazyVStack(spacing: 16) {
                    ForEach(context.reminders.filter(Filters.any(of: reminderFilters).filter)) { item in
                        PreviewCalItemView(item: item)
                    }
                    Divider()
                        .overlay { Color.red }
                    ForEach(context.events.filter(Filters.any(of: eventFilters).filter)) { item in
                        PreviewCalItemView(item: item)
                    }
                }
                .padding()
            }
            .navigationTitle(Date.now.formatted())
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct PreviewCalItemView: View {

    let item: CalItem

    var body: some View {

        VStack(alignment: .leading) {
            HStack {
                Text(item.title)
                    .font(.title3)
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .fill(.clear)
                .stroke(Color.primary.quaternary, lineWidth: 0.5)
        }

    }

}

struct PreviewEventView: View {

    let event: EKEvent

    var body: some View {

        VStack(alignment: .leading) {
            HStack {
                Text(event.title)
                    .font(.title3)
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .fill(.clear)
                .stroke(Color.primary.quaternary, lineWidth: 0.5)
        }

    }

}

struct PreviewReminderView: View {

    let reminder: EKReminder

    var body: some View {

        VStack(alignment: .leading) {
            HStack {
                Text(reminder.title)
                    .font(.title3)
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .fill(.clear)
                .stroke(Color.primary.quaternary, lineWidth: 0.5)
        }

    }

}

typealias CalItem = EKCalendarItem
