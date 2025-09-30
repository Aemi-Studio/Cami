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

    @State private var event: EKEvent

    init() {
        self.event = DataContext.shared.createEvent()
    }

    var body: some View {
        EventCreationView()
            .navigationTitle(String(localized: "create.\(CalendarItem.Kind.event.description)"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItemGroup(placement: .confirmationAction) {
                    Button("Save") {
                        if let data,
                           (try? data.createReminder(title: "")) != nil
                        {
                            dismiss()
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
                                    Text("Event")
                                        .foregroundColor(.white)
                                        .padding(.horizontal)

                                    Text("Reminder")
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
                    TextField("Title", text: $title)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal)

                    // Notes Field
                    TextField("Notes", text: $notes)
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

                            Text("Date")
                                .foregroundColor(.white)
                                .font(.headline)

                            Spacer()

                            Text("Today")
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

                            Text("Time")
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

                        Text("Repeat")
                            .foregroundColor(.white)
                            .font(.headline)

                        Spacer()

                        Text("Never")
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

                        Text("List")
                            .foregroundColor(.white)
                            .font(.headline)

                        Spacer()

                        Text("Reminders")
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
                        Text("Details")
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
                            Text("Calendar")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }

                        VStack {
                            Image(systemName: "paperplane")
                                .foregroundColor(.gray)
                            Text("Mail")
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
                    Text("New")
                        .font(.headline)
                        .foregroundColor(.white)
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        // Cancel action
                    }
                    .foregroundColor(.red)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
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

                        Text("Location")
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

                        Text("Priority")
                            .foregroundColor(.white)
                            .font(.headline)

                        Spacer()

                        Text("None")
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
                    Text("Details")
                        .font(.headline)
                        .foregroundColor(.white)
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("New Reminder")
                        }
                        .foregroundColor(.red)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
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
        ContentView()
            .colorScheme(.dark)
    }
}
