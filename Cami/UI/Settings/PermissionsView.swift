//
//  PermissionsView.swift
//  Cami
//
//  Created by Guillaume Coquard on 15/11/23.
//

import SwiftUI

struct PermissionsView: View {
    @Environment(PermissionManager.self) private var manager

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 16) {
                CustomSection {
                    AccessToggle(
                        isOn: manager.calendarStatus,
                        title: String(localized: "perms.calendars.title", comment: ""),
                        description: String(localized: "perms.calendars.description", comment: ""),
                        action: { await manager.request(.calendar) }
                    )

                    AccessToggle(
                        isOn: manager.contactsStatus,
                        title: String(localized: "perms.contacts.title", comment: ""),
                        description: String(localized: "perms.contacts.description", comment: ""),
                        action: { await manager.request(.contacts) }
                    )

                    AccessToggle(
                        isOn: manager.remindersStatus,
                        title: String(localized: "perms.reminders.title", comment: ""),
                        description: String(localized: "perms.reminders.description", comment: ""),
                        action: { await manager.request(.reminders) }
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
