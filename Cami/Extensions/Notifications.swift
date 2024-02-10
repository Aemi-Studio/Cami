//
//  Notifications.swift
//  Cami
//
//  Created by Guillaume Coquard on 10/02/24.
//

import Foundation

extension Notification.Name {
    static let requestEventsAccess = Notification.Name("requestEventsAccess")
    static let requestContactsAccess = Notification.Name("requestContactsAccess")
    static let requestRemindersAccess = Notification.Name("requestRemindersAccess")
    static let requestAccess = Notification.Name("requestAccess")
    static let eventsAccessUpdated = Notification.Name("eventsAccessUpdated")
    static let contactsAccessUpdated = Notification.Name("contactsAccessUpdated")
    static let remindersAccessUpdated = Notification.Name("remindersAccessUpdated")
    static let accessUpdated = Notification.Name("accessUpdated")
}
