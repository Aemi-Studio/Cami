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
        ScrollView(.vertical) {
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
                            Text("Calendars")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }

                        Group {
                            Text("""
    Cami ONLY uses your on-device calendar information to display events in widgets.
    """)
                            Text("""
    Cami DOES NOT edit or delete or send those information away.
    """)
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.foreground.secondary)
                        .multilineTextAlignment(.leading)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                #if DEBUG
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
                #endif
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
                            Text("Contacts")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }

                        Group {
                            Text("""
    Cami ONLY uses your on-device contacts information to display birthday information in widgets.
    """)
                            Text("""
    Cami DOES NOT edit or delete or send those information away.
    """)
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.foreground.secondary)
                        .multilineTextAlignment(.leading)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                SettingsLinkView(radius: 8)
                WidgetHelpView(
                    title: "Privacy Policy",
                    url: "https://aemi.studio/privacy",
                    description: "Review how Cami handles your data.",
                    radius: 8
                )
            }
            .padding()
            .lineLimit(10)
        }
    }
}
