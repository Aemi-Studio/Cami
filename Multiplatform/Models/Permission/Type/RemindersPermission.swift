//
//  RemindersPermission.swift
//  Cami
//
//  Created by Guillaume Coquard on 28.09.25.
//

struct RemindersPermission: PermissionType {
    let title = String(localized: "permission.type.reminders.title")
    let systemSettingsPath = "root=Privacy&path=REMINDERS"
    let symbolName = "" // TODO: Add symbol for reminders
    let description = String(localized: "permission.type.reminders.description")
}
