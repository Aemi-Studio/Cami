//
//  PermissionsView.swift
//  Cami
//
//  Created by Guillaume Coquard on 15/11/23.
//

import SwiftUI

struct PermissionsView: View {
    @Environment(\.permissions) private var permissions

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 16) {
                CustomSection {
                    AccessToggle(
                        isOn: permissions.calendars,
                        title: String(localized: "perms.calendars.title", comment: ""),
                        description: String(localized: "perms.calendars.description", comment: ""),
                        action: { await permissions.request(access: .calendars) }
                    )

                    AccessToggle(
                        isOn: permissions.contacts,
                        title: String(localized: "perms.contacts.title", comment: ""),
                        description: String(localized: "perms.contacts.description", comment: ""),
                        action: { await permissions.request(access: .contacts) }
                    )

                    AccessToggle(
                        isOn: permissions.reminders,
                        title: String(localized: "perms.reminders.title", comment: ""),
                        description: String(localized: "perms.reminders.description", comment: ""),
                        action: { await permissions.request(access: .reminders) }
                    )
                }
                CustomSection {
                    PrivacyPolicyButton()
                    SystemSettingsButton()
                }
            }
            .padding(.horizontal)
            .navigationTitle(String(localized: "view.permissions.title"))
        }
    }
}
