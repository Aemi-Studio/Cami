//
//  CalendarPermission.swift
//  Cami
//
//  Created by Guillaume Coquard on 28.09.25.
//

struct CalendarPermission: PermissionType {
    let title = String(localized: "permission.type.calendar.title")
    let systemSettingsPath = "root=Privacy&path=CALENDARS"
    let symbolName = "calendar"
    let description = String(localized: "permission.type.calendar.description")
}
