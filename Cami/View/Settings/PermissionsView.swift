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

    var body: some View {
        if let permissions {
            NavigationView {
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 16) {
                        @Bindable var permissions = permissions

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

                        if permissions.global == .authorized {
                            SettingsLinkView(radius: 12)
                            WidgetHelpView(
                                title: "Privacy Policy",
                                url: "https://aemi.studio/privacy",
                                description: "Review how Cami handles your data.",
                                radius: 12
                            )
                        } else {
                            WidgetHelpView(
                                title: "Privacy Policy",
                                url: "https://aemi.studio/privacy",
                                description: "Review how Cami handles your data.",
                                radius: 12
                            )
                            SettingsLinkView(radius: 12)
                        }

                    }
                    .padding()
                }
                .navigationTitle(NSLocalizedString("view.permissions.title", comment: ""))
                .navigationBarTitleDisplayMode(viewKind == .sheet ? .inline : .large)
            }
        }
    }
}
