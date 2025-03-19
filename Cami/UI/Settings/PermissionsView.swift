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
                        title: NSLocalizedString("perms.calendars.title", comment: ""),
                        description: NSLocalizedString("perms.calendars.description", comment: ""),
                        action: { await permissions.request(access: .calendars) }
                    )

                    AccessToggle(
                        isOn: permissions.contacts,
                        title: NSLocalizedString("perms.contacts.title", comment: ""),
                        description: NSLocalizedString("perms.contacts.description", comment: ""),
                        action: { await permissions.request(access: .contacts) }
                    )

                    AccessToggle(
                        isOn: permissions.reminders,
                        title: NSLocalizedString("perms.reminders.title", comment: ""),
                        description: NSLocalizedString("perms.reminders.description", comment: ""),
                        action: { await permissions.request(access: .reminders) }
                    )
                }
                CustomSection {
                    PrivacyPolicyButton()
                    SystemSettingsButton()
                }
            }
            .padding(.horizontal)
            .set(\.title, to: String(localized: "view.permissions.title"))
        }
    }
}
