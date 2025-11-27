//
//  CreateCalendarItemView.swift
//  Cami
//
//  Created by Guillaume Coquard on 10/03/25.
//

import EventKit
import SwiftUI

struct CreateCalendarItemView: View {
    @Environment(\.data) private var data
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        EventCreationView()
            .navigationTitle(String(localized: "create.\(CalendarItemKind.event.description)"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .cancellationAction) {
                    Button(String(localized: "button.cancel")) {
                        dismiss()
                    }
                }
                ToolbarItemGroup(placement: .confirmationAction) {
                    Button(String(localized: "button.save")) {
                        Task {
                            if let data {
                                _ = try? await data.createReminder(title: "")
                                dismiss()
                            }
                        }
                    }
                    .disabled(true)
                }
            }
    }
}

// MARK: - Reminder Creation View (Second Screen)

struct ReminderCreationView: View {
    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var isTimeEnabled: Bool = true

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                VStack {
                    // Event/Reminder Segmented Control
                    HStack {
                        Capsule()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 40)
                            .overlay(
                                HStack {
                                    Text(String(localized: "calendarItem.kind.event"))
                                        .foregroundColor(.white)
                                        .padding(.horizontal)

                                    Text(String(localized: "calendarItem.kind.reminder"))
                                        .foregroundColor(.white)
                                        .padding(.horizontal)
                                        .background(
                                            Capsule()
                                                .fill(Color.gray.opacity(0.5))
                                        )
                                }
                            )
                    }
                    .padding(.horizontal)

                    // Title Field
                    TextField(String(localized: "field.title.placeholder"), text: $title)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal)

                    // Notes Field
                    TextField(String(localized: "field.notes.placeholder"), text: $notes)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal)

                    // Date & Time Section
                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.red)
                                .frame(width: 30)

                            Text(String(localized: "label.date"))
                                .foregroundColor(.white)
                                .font(.headline)

                            Spacer()

                            Text(String(localized: "label.today"))
                                .foregroundColor(.red)
                        }
                        .padding()

                        Divider()
                            .background(Color.gray.opacity(0.3))
                            .padding(.leading, 50)

                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.blue)
                                .frame(width: 30)

                            Text(String(localized: "label.time"))
                                .foregroundColor(.white)
                                .font(.headline)

                            Spacer()

                            Text("23:00")
                                .foregroundColor(.red)

                            Toggle("", isOn: $isTimeEnabled)
                                .labelsHidden()
                                .tint(.green)
                        }
                        .padding()
                    }
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)

                    // Repeat Section
                    HStack {
                        Image(systemName: "arrow.2.squarepath")
                            .foregroundColor(.gray)
                            .frame(width: 30)

                        Text(String(localized: "label.repeat"))
                            .foregroundColor(.white)
                            .font(.headline)

                        Spacer()

                        Text(String(localized: "repeat.frequency.never"))
                            .foregroundColor(.gray)

                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)

                    // List Section
                    HStack {
                        Image(systemName: "list.bullet")
                            .foregroundColor(.blue)
                            .frame(width: 30)

                        Text(String(localized: "label.list"))
                            .foregroundColor(.white)
                            .font(.headline)

                        Spacer()

                        Text(String(localized: "calendarItem.kind.reminder.plural"))
                            .foregroundColor(.gray)

                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)

                    // Details Section
                    HStack {
                        Text(String(localized: "label.details"))
                            .foregroundColor(.white)
                            .font(.headline)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)

                    Spacer()

                    // Tab Bar
                    HStack(spacing: 100) {
                        VStack {
                            Image(systemName: "calendar.badge.plus")
                                .foregroundColor(.blue)
                            Text(String(localized: "label.calendar"))
                                .font(.caption)
                                .foregroundColor(.blue)
                        }

                        VStack {
                            Image(systemName: "paperplane")
                                .foregroundColor(.gray)
                            Text(String(localized: "label.mail"))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                }
                .padding(.top)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(String(localized: "action.new"))
                        .font(.headline)
                        .foregroundColor(.white)
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "button.cancel")) {
                        // Cancel action
                    }
                    .foregroundColor(.red)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "button.add")) {
                        // Add action
                    }
                    .foregroundColor(.gray)
                }
            }
        }
        .colorScheme(.dark)
    }
}

// MARK: - Reminder Details View (Third Screen)

struct ReminderDetailsView: View {
    @State private var isLocationEnabled: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                VStack {
                    // Location Section
                    HStack {
                        Image(systemName: "location")
                            .foregroundColor(.blue)
                            .frame(width: 30)

                        Text(String(localized: "label.location"))
                            .foregroundColor(.white)
                            .font(.headline)

                        Spacer()

                        Toggle("", isOn: $isLocationEnabled)
                            .labelsHidden()
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)

                    // Priority Section
                    HStack {
                        Image(systemName: "exclamationmark.circle")
                            .foregroundColor(.red)
                            .frame(width: 30)

                        Text(String(localized: "label.priority"))
                            .foregroundColor(.white)
                            .font(.headline)

                        Spacer()

                        Text(String(localized: "priority.none"))
                            .foregroundColor(.gray)

                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.top)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(String(localized: "label.details"))
                        .font(.headline)
                        .foregroundColor(.white)
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text(String(localized: "action.newReminder"))
                        }
                        .foregroundColor(.red)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "button.add")) {
                        // Add action
                    }
                    .foregroundColor(.gray)
                }
            }
        }
        .colorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppRootView()
            .colorScheme(.dark)
    }
}
