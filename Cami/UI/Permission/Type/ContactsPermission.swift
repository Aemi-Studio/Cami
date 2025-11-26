//
//  ContactsPermission.swift
//  Cami
//
//  Created by Guillaume Coquard on 28.09.25.
//

struct ContactsPermission: PermissionType {
    let title = String(localized: "permission.type.contacts.title")
    let systemSettingsPath = "root=Privacy&path=CALENDARS"
    let symbolName = "" // TODO: Add symbol for reminders
    let description = String(localized: "permission.type.contacts.description")
}
