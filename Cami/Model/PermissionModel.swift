//
//  PermissionModel.swift
//  Cami
//
//  Created by Guillaume Coquard on 10/02/24.
//

import EventKit
import Contacts
import Combine
import SwiftUI

@Observable
final class PermissionModel: Loggable {

    static let shared: PermissionModel = .init()
    static let center: NotificationCenter = .init()

    private(set) var events: PermissionSet = .none
    private(set) var contacts: PermissionSet = .none
    private(set) var reminders: PermissionSet = .none

    var global: PermissionSet = .none

    private init() {
        log.debug("Initializing Permissions Statuses")

        self.events = switch EKEventStore.authorizationStatus(for: .event) {
        case .fullAccess:
            PermissionSet.calendars
        case .notDetermined:
            PermissionSet.none
        default:
            PermissionSet.restrictedCalendars
        }

        self.contacts = switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            PermissionSet.contacts
        case .notDetermined:
            PermissionSet.none
        default:
            PermissionSet.restrictedContacts
        }

        self.reminders = switch EKEventStore.authorizationStatus(for: .reminder) {
        case .fullAccess:
            PermissionSet.reminders
        case .notDetermined:
            PermissionSet.none
        default:
            PermissionSet.restrictedReminders
        }

        self.global = PermissionSet([
            self.events,
            self.contacts,
            self.reminders
        ])

        self.addObservers()
    }

    deinit {
        removeObservers()
    }
}

// MARK: Notification Observer
extension PermissionModel {

    @objc func requestAccess() async {
        log.debug("Requesting Full Access")
        self.requestCalendarsAccess()
        self.requestContactsAccess()
        self.requestRemindersAccess()
    }

    @objc func requestCalendarsAccess() {
        log.debug("Requesting Calendars Access")
        EventHelper.requestCalendarsAccess { result in
            self.log.debug("\(String(describing: result))")
            Self.center.post(name: .calendarsAccessUpdated, object: nil)
        }
    }

    @objc func requestContactsAccess() {
        log.debug("Requesting Contacts Access")
        ContactHelper.requestAccess { result in
            self.log.debug("\(String(describing: result))")
            Self.center.post(name: .contactsAccessUpdated, object: nil)
        }
    }

    @objc func requestRemindersAccess() {
        log.debug("Requesting Reminders Access")
        EventHelper.requestRemindersAccess { result in
            self.log.debug("\(String(describing: result))")
            Self.center.post(name: .remindersAccessUpdated, object: nil)
        }
    }

    @objc private func updateAccess() {
        log.debug("Updating Access")

        self.events = switch EKEventStore.authorizationStatus(for: .event) {
        case .fullAccess:
            AuthSet.calendars
        case .notDetermined:
            AuthSet.none
        default:
            AuthSet.restrictedCalendars
        }

        self.contacts = switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            AuthSet.contacts
        case .notDetermined:
            AuthSet.none
        default:
            AuthSet.restrictedContacts
        }

        self.reminders = switch EKEventStore.authorizationStatus(for: .reminder) {
        case .fullAccess:
            AuthSet.reminders
        case .notDetermined:
            AuthSet.none
        default:
            AuthSet.restrictedReminders
        }

        self.global = PermissionSet([
            self.events,
            self.contacts,
            self.reminders
        ])
    }

    private func addObservers() {
        Self.center.addObserver(
            self,
            selector: #selector(requestCalendarsAccess),
            name: .requestAccess, object: nil
        )
        Self.center.addObserver(
            self,
            selector: #selector(requestCalendarsAccess),
            name: .requestCalendarsAccess, object: nil
        )
        Self.center.addObserver(
            self,
            selector: #selector(requestContactsAccess),
            name: .requestContactsAccess, object: nil
        )
        Self.center.addObserver(
            self,
            selector: #selector(requestRemindersAccess),
            name: .requestRemindersAccess, object: nil
        )

        Self.center.addObserver(
            self,
            selector: #selector(updateAccess),
            name: .calendarsAccessUpdated, object: nil
        )
        Self.center.addObserver(
            self,
            selector: #selector(updateAccess),
            name: .contactsAccessUpdated, object: nil
        )
        Self.center.addObserver(
            self,
            selector: #selector(updateAccess),
            name: .remindersAccessUpdated, object: nil
        )
    }

    private func removeObservers() {
        Self.center.removeObserver(self, name: .requestAccess, object: nil)
        Self.center.removeObserver(self, name: .requestCalendarsAccess, object: nil)
        Self.center.removeObserver(self, name: .requestContactsAccess, object: nil)
        Self.center.removeObserver(self, name: .requestRemindersAccess, object: nil)
        Self.center.removeObserver(self, name: .calendarsAccessUpdated, object: nil)
        Self.center.removeObserver(self, name: .contactsAccessUpdated, object: nil)
        Self.center.removeObserver(self, name: .remindersAccessUpdated, object: nil)
    }

}

extension EnvironmentValues {
    @Entry var permissions: PermissionModel?
}
