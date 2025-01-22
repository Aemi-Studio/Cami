//
//  SettingsView.swift
//  Cami
//
//  Created by Guillaume Coquard on 15/11/23.
//

import SwiftUI

struct PermissionsView: View {

    @Environment(\.dismiss) private var dismiss: DismissAction
    @Environment(\.permissions) private var permissions

    @State private var calInfo: Bool = false
    @State private var remInfo: Bool = false
    @State private var conInfo: Bool = false

    @AppStorage("accessWorkInProgressFeatures")
    private var accessWorkInProgressFeatures = false

    var body: some View {
        if let permissions {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 16) {

                    // swiftlint:disable line_length
                    PermissionAccessSection(
                        status: permissions.global.calendars,
                        title: "Calendars",
                        label: "Access to calendars authorized",
                        notificationName: .requestCalendarsAccess,
                        description: "Cami ONLY uses your on-device calendar information to display events in widgets.\n\nCami DOES NOT edit, delete, save or send those information away.",
                        restrictedDescription: "Review Cami access to your calendars."
                    )

                    PermissionAccessSection(
                        status: permissions.global.contacts,
                        title: "Contacts",
                        label: "Access to contacts authorized",
                        notificationName: .requestContactsAccess,
                        description: "Cami ONLY uses your on-device contacts information to display birthdays information in widgets.\n\nCami DOES NOT edit, delete, save or send those information away.",
                        restrictedDescription: "Review Cami access to your contacts."
                    )

                    if accessWorkInProgressFeatures {
                        PermissionAccessSection(
                            status: permissions.global.reminders,
                            title: "Reminders",
                            label: "Access to reminders authorized",
                            notificationName: .requestRemindersAccess,
                            description: "Cami ONLY uses your on-device reminders information to display them in widgets and the application.\n\nCami DOES NOT edit, delete, save or send those information away.",
                            restrictedDescription: "Review Cami access to your reminders."
                        )
                    }
                    // swiftlint:enable line_length

                    if permissions.global.isDisjoint(with: .restricted) {
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
            .if(permissions.global.isDisjoint(with: .restricted)) { view in
                NavigationView {
                    view
                        .navigationTitle("Permissions")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
}
