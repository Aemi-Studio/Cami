//
//  ReminderDetailView.swift
//  Cami
//
//  Created by Guillaume Coquard on 27/11/25.
//

import EventKit
import SwiftUI

/// Wrapper view that fetches a reminder by identifier and displays it
struct ReminderDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.data) private var dataContext

    let identifier: String

    @State private var reminder: EKReminder?
    @State private var isLoading = true
    @State private var isCompleting = false

    var body: some View {
        NavigationStack {
            Group {
                if let reminder {
                    reminderContent(reminder)
                } else if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ContentUnavailableView(
                        "Reminder Not Found",
                        systemImage: "checklist.unchecked",
                        description: Text("The reminder could not be found or has been deleted.")
                    )
                }
            }
            .navigationTitle("Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await loadReminder()
        }
    }

    @ViewBuilder
    private func reminderContent(_ reminder: EKReminder) -> some View {
        List {
            Section {
                HStack {
                    Button {
                        Task {
                            await toggleCompletion(reminder)
                        }
                    } label: {
                        Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.title2)
                            .foregroundStyle(Color(reminder.calendar.cgColor))
                    }
                    .buttonStyle(.plain)
                    .disabled(isCompleting)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(reminder.title ?? "Untitled")
                            .font(.headline)
                            .strikethrough(reminder.isCompleted)

                        if let dueDate = reminder.dueDateComponents?.date {
                            Text(dueDate, style: .date)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            if let notes = reminder.notes, !notes.isEmpty {
                Section("Notes") {
                    Text(notes)
                        .font(.body)
                }
            }

            Section {
                LabeledContent("List", value: reminder.calendar.title)

                if reminder.priority > 0 {
                    LabeledContent("Priority") {
                        priorityView(for: reminder.priority)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func priorityView(for priority: Int) -> some View {
        HStack(spacing: 2) {
            ForEach(0..<min(priority, 3), id: \.self) { _ in
                Image(systemName: "exclamationmark")
                    .font(.caption)
            }
        }
        .foregroundStyle(.red)
    }

    private func loadReminder() async {
        isLoading = true
        reminder = await MainActor.run {
            dataContext?.eventStore.calendarItem(withIdentifier: identifier) as? EKReminder
        }
        isLoading = false
    }

    private func toggleCompletion(_ reminder: EKReminder) async {
        guard let dataContext else { return }
        isCompleting = true
        let success = await dataContext.completeReminder(withIdentifier: identifier)
        if success {
            await loadReminder()
        }
        isCompleting = false
    }
}
