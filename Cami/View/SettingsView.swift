//
//  SettingsView.swift
//  Cami
//
//  Created by Guillaume Coquard on 15/11/23.
//

import SwiftUI

struct SettingsView: View {

    @Environment(ViewModel.self)
    private var model: ViewModel

    @State private var calInfo: Bool = false
    @State private var remInfo: Bool = false
    @State private var conInfo: Bool = false

    private func statusToSymbolName(_ status: AuthSet.Status) -> String {
        switch status {
            case .authorized:
                "checkmark.circle.fill"
            case .restricted:
                "xmark.circle.fill"
            case .notDetermined:
                "circle"
        }
    }
    private func statusToStatusColor(_ status: AuthSet.Status) -> Color {
        switch status {
            case .authorized:
                    .blue
            case .restricted:
                    .red
            case .notDetermined:
                    .gray
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack(alignment: .center, spacing: 16) {
                    Button {
                        Task {
                            if !Bool(model.authStatus.calendars.status) {
                                model.authStatus.insert(await CalendarHelper.requestAccess())
                            }
                        }
                    } label: {
                        Label("Enable Calendars Access", systemImage: statusToSymbolName(model.authStatus.calendars.status))
                            .labelStyle(.iconOnly)
                            .foregroundStyle(statusToStatusColor(model.authStatus.calendars.status))
                    }
                    .font(.title)
                    .buttonStyle(PlainButtonStyle())
                    .disabled(model.authStatus.calendars.status == .authorized)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Calendars Access")
                                .font(.title)
                                .fontWeight(.semibold)

                            Spacer()

                            Button {
                                calInfo.toggle()
                            } label: {
                                Label("Information", systemImage: "info.circle")
                                    .labelStyle(.iconOnly)
                            }
                            .foregroundStyle(.foreground.secondary)
                            .buttonStyle(PlainButtonStyle())
                            .navigationDestination(isPresented: $calInfo) {
                                ScrollView {
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text("Calendars Access")
                                            .font(.title)
                                            .fontWeight(.bold)
                                        Text("""
        Cami only uses your data locally to display events. It does not edit or delete them nor sends them away.
        """)
                                    }
                                    .padding()
                                }
                            }
                        }

                        Text("Used to display events in the calendar and the widget.")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.foreground.secondary)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                HStack(alignment: .center, spacing: 16) {

                    Button {
                        Task {
                            if !Bool(model.authStatus.reminders.status) {
                                model.authStatus.insert(await ReminderHelper.requestAccess())
                            }
                        }
                    } label: {
                        Label("Enable Reminders Access", systemImage: statusToSymbolName(model.authStatus.reminders.status))
                            .labelStyle(.iconOnly)
                            .foregroundStyle(statusToStatusColor(model.authStatus.reminders.status))
                    }
                    .font(.title)
                    .buttonStyle(PlainButtonStyle())
                    .disabled(model.authStatus.reminders.status == .authorized)


                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Reminders Access")
                                .font(.title)
                                .fontWeight(.semibold)

                            Spacer()

                            Button {
                                remInfo.toggle()
                            } label: {
                                Label("Information", systemImage: "info.circle")
                                    .labelStyle(.iconOnly)
                            }
                            .foregroundStyle(.foreground.secondary)
                            .buttonStyle(PlainButtonStyle())
                            .navigationDestination(isPresented: $remInfo) {
                                ScrollView {
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text("Reminders Access")
                                            .font(.title)
                                            .fontWeight(.bold)
                                        Text("""
        Cami only uses your data locally to display reminders. It does not edit or delete them nor sends them away.
        """)
                                    }
                                    .padding()
                                }
                            }

                        }

                        Text("Used to display reminders in the calendar and the widget.")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.foreground.secondary)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                HStack(alignment: .center, spacing: 16) {

                    Button {
                        Task {
                            if !Bool(model.authStatus.contacts.status) {
                                model.authStatus.insert(await ContactHelper.requestAccess())
                            }
                        }
                    } label: {
                        Label("Enable Contacts Access", systemImage: statusToSymbolName(model.authStatus.contacts.status))
                            .labelStyle(.iconOnly)
                            .foregroundStyle(statusToStatusColor(model.authStatus.contacts.status))
                    }
                    .font(.title)
                    .buttonStyle(PlainButtonStyle())
                    .disabled(model.authStatus.contacts.status == .authorized)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Contacts Access")
                                .font(.title)
                                .fontWeight(.semibold)

                            Spacer()

                            Button {
                                conInfo.toggle()
                            } label: {
                                Label("Information", systemImage: "info.circle")
                                    .labelStyle(.iconOnly)
                            }
                            .foregroundStyle(.foreground.secondary)
                            .buttonStyle(PlainButtonStyle())
                            .navigationDestination(isPresented: $conInfo) {
                                ScrollView {
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text("Contact Access Information")
                                            .font(.title)
                                            .fontWeight(.bold)
                                        Text("""
            Cami only uses your contacts information locally to display events and reminders customization. It does not edit or delete them nor sends them away.
            """)
                                    }
                                    .padding()
                                }
                            }
                        }

                        Text("Used to display and customize events and reminders in the calendar and the widget.")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.foreground.secondary)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .font(.title2)
            .padding()
        }
    }
}
