//
//  EventCreationView.swift
//  Cami
//
//  Created by Guillaume Coquard on 02/04/25.
//

import EventKit
import SwiftUI

final class Streak: EKCalendarItem {
    override var hasRecurrenceRules: Bool {
        true
    }
}

struct CalendarItemTimeInput: View {

    @Binding private(set) var item: EKCalendarItem

    var kind: CalendarItemKind? {
        switch item {
            case is EKEvent: .event
            case is EKReminder: .reminder
            case is Streak: .streak
            default: .none
        }
    }

    var body: some View {
        switch item {
            case is EKEvent:
                eventTimeInput()
            case is EKReminder:
                reminderTimeInput()
            case is Streak:
                streakTimeInput()
            default:
                EmptyView()
        }
    }

    /// Time Input should have a setting, for events:
    /// - isAllDay, Start Date, End date (if not all day), recurrence rules
    /// For reminders:
    /// - Due date, Start date, recurrence rules
    /// For streaks:
    /// - Start date, recurrence rules

    @ViewBuilder func reminderTimeInput() -> some View {}

    @ViewBuilder func eventTimeInput() -> some View {}

    @ViewBuilder func streakTimeInput() -> some View {}

    var intervalView: some View {
        VStack {}
    }
}

struct EventCreationView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.data) private var data

    @State private var event: EKEvent?
    @State private var title: String = ""

    var body: some View {
        ScrollView(.vertical) {
            VStack {
                ItemTitleInput(prompt: "Title", title: $title)
            }
        }
        .task {
            if let data {
                event = await data.createEvent()
            }
        }
        .onChange(of: title) { _, newValue in
            event?.title = newValue
        }
    }
}

struct ItemTitleInput: View {

    @State private var model = ItemTitleInputViewModel()

    let prompt: String
    @Binding private(set) var title: String

    var body: some View {
        VStack(spacing: 8) {
            TextField(prompt, text: $title)
                .padding()
                .padding(.horizontal)

            suggestedItems
        }
        .onChange(of: title) { _, newValue in
            Task { await model.updateSuggestions(for: newValue) }
        }
    }

    @ViewBuilder var suggestedItems: some View {
        if !model.suggestions.isEmpty {
            Divider()
            ForEach(model.suggestions.indices, id: \.self) { index in
                Text(model.suggestions[index])
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                if index < model.suggestions.endIndex - 1 {
                    Divider()
                }
            }
        }
    }

}

@Observable
final class ItemTitleInputViewModel<Kind> where Kind: EKCalendarItem {
    typealias Provider = @Sendable (String) async -> [Kind]

    private let provider: Provider
    private(set) var suggestedItems: [Kind] = []
    var suggestions: [String] {
        suggestedItems.compactMap(\.title)
    }

    init(provider: @escaping Provider = { _ in [] }) {
        self.provider = provider
    }

    func updateSuggestions(for title: String) async {
        guard !title.isEmpty else {
            suggestedItems = []
            return
        }
        suggestedItems = await provider(title)
    }
}

#Preview {
    EventCreationView()
}
