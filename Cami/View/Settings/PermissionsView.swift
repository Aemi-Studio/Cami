//
//  SettingsView.swift
//  Cami
//
//  Created by Guillaume Coquard on 15/11/23.
//

extension Binding {

    var forcedProjectedValue: Binding<Value> {
        Binding<Value> {
            self.wrappedValue
        } set: { _ in }
    }

}

import SwiftUI

struct PermissionsView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.viewKind) private var viewKind
    @Environment(\.permissions) private var permissions
    @Environment(\.presentation) private var presentation

    var body: some View {
        if let permissions {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 16) {
                    @Bindable var permissions = permissions

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
            }
            .setNavigationPage(\.title, to: String(localized: "view.permissions.title"))
        }
    }
}
