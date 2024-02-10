//
//  SettingsView.swift
//  Cami
//
//  Created by Guillaume Coquard on 15/11/23.
//

import SwiftUI

struct SettingsView: View {

    @Environment(\.dismiss)
    private var dismiss: DismissAction

    @Environment(PermissionModel.self)
    private var perms: PermissionModel

    @State private var calInfo: Bool = false
    @State private var remInfo: Bool = false
    @State private var conInfo: Bool = false

    @AppStorage("accessWorkInProgressFeatures")
    private var accessWorkInProgressFeatures = false

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Group {
                            Text("Calendars")
                                .font(.title2)

                            if perms.global.calendars.status == .authorized {
                                Label("Access to calendars authorized", systemImage: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                    .labelStyle(.iconOnly)
                            }
                        }
                        .fontWeight(.semibold)

                        Spacer()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cami ONLY uses your on-device calendar information to display events in widgets.")
                        Text("Cami DOES NOT edit or delete or send those information away.")
                    }
                    .frame(maxHeight: .infinity)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.foreground.secondary)
                    .multilineTextAlignment(.leading)

                    switch perms.global.calendars.status {
                    case .notDetermined:
                        Button {
                            NotificationCenter.default.post(name: .requestEventsAccess, object: nil)
                        } label: {
                            ButtonInnerBody(label: "Authorize", radius: 8, border: true, noIcon: true)
                                .tint(.blue)
                        }
                    case .authorized:
                        EmptyView()
                    case .restricted:
                        Button {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        } label: {
                            ButtonInnerBody(
                                label: "Restricted",
                                description: "Review Cami access to your calendars.",
                                systemImage: "gear",
                                radius: 8,
                                border: true
                            )
                            .tint(.red)
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                if accessWorkInProgressFeatures {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 8) {
                            Group {
                                Text("Reminders")
                                    .font(.title2)

                                if perms.global.reminders.status == .authorized {
                                    Label("Access to reminders authorized", systemImage: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                        .labelStyle(.iconOnly)
                                }
                            }
                            .fontWeight(.semibold)

                            Spacer()
                        }

                        Text("Used to display reminders in the calendar and the widget.")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.foreground.secondary)

                        switch perms.global.reminders.status {
                        case .notDetermined:
                            Button {
                                NotificationCenter.default.post(name: .requestRemindersAccess, object: nil)
                            } label: {
                                ButtonInnerBody(label: "Authorize", radius: 8, border: true, noIcon: true)
                                    .tint(.blue)
                            }
                        case .authorized:
                            EmptyView()
                        case .restricted:
                            Button {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                }
                            } label: {
                                ButtonInnerBody(
                                    label: "Restricted",
                                    description: "Review Cami access to your reminders.",
                                    systemImage: "gear",
                                    radius: 8,
                                    border: true
                                )
                                .tint(.red)
                            }
                        }
                    }
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Group {
                            Text("Contacts")
                                .font(.title2)

                            if perms.global.contacts.status == .authorized {
                                Label("Access to contacts authorized", systemImage: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                    .labelStyle(.iconOnly)
                            }
                        }
                        .fontWeight(.semibold)

                        Spacer()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cami ONLY uses your on-device contacts information to display birthday information in widgets.")
                        Text("Cami DOES NOT edit or delete or send those information away.")
                    }
                    .frame(maxHeight: .infinity)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.foreground.secondary)
                    .multilineTextAlignment(.leading)

                    switch perms.global.contacts.status {
                    case .notDetermined:
                        Button {
                            NotificationCenter.default.post(name: .requestContactsAccess, object: nil)
                        } label: {
                            ButtonInnerBody(
                                label: "Authorize",
                                radius: 8,
                                border: true,
                                noIcon: true
                            )
                            .tint(.blue)
                        }
                    case .authorized:
                        EmptyView()
                    case .restricted:
                        Button {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(
                                    url,
                                    options: [:],
                                    completionHandler: nil
                                )
                            }
                        } label: {
                            ButtonInnerBody(
                                label: "Restricted",
                                description: "Review Cami access to your contacts.",
                                systemImage: "gear",
                                radius: 8,
                                border: true
                            )
                            .tint(.red)
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                if perms.global.calendars.status == .authorized
                    && perms.global.contacts.status == .authorized {
                    SettingsLinkView(radius: 12)
                }

                WidgetHelpView(
                    title: "Privacy Policy",
                    url: "https://aemi.studio/privacy",
                    description: "Review how Cami handles your data.",
                    radius: 12
                )
            }
            .padding()
        }
    }
}
