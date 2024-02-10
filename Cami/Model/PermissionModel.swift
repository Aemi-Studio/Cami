//
//  PermissionModel.swift
//  Cami
//
//  Created by Guillaume Coquard on 10/02/24.
//

import Foundation
import EventKit
import Contacts

@Observable
final class PermissionModel: ObservableObject {

    static let shared: PermissionModel = .init()

    private let center: NotificationCenter = .default

    private var events: AuthorizationSet = .none {
        didSet {
            self.center.post(name: .eventsAccessUpdated, object: nil)
        }
    }
    private var contacts: AuthorizationSet = .none {
        didSet {
            self.center.post(name: .contactsAccessUpdated, object: nil)
        }
    }
    private var reminders: AuthorizationSet = .none {
        didSet {
            self.center.post(name: .remindersAccessUpdated, object: nil)
        }
    }

    var global: AuthorizationSet = .none {
        didSet {
            self.center.post(name: .accessUpdated, object: nil)
        }
    }

    private init() {

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

        self.global = AuthorizationSet([
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

    @objc private func requestAccess() {
        self.requestEventsAccess()
        self.requestContactsAccess()
        self.requestRemindersAccess()
    }

    @objc private func requestEventsAccess() {
        CalendarHelper.requestAccess { result in
            self.events = result
        }
    }

    @objc private func requestContactsAccess() {
        ContactHelper.requestAccess { result in
            self.contacts = result
        }
    }

    @objc private func requestRemindersAccess() {
        ReminderHelper.requestAccess { result in
            self.reminders = result
        }
    }

    @objc private func updateAccess() {
        self.global = AuthorizationSet([
            self.events,
            self.contacts,
            self.reminders
        ])
    }

    private func addObservers() {
        self.center.addObserver(
            self,
            selector: #selector(requestAccess),
            name: .requestAccess, object: nil
        )
        self.center.addObserver(
            self,
            selector: #selector(requestEventsAccess),
            name: .requestEventsAccess, object: nil
        )
        self.center.addObserver(
            self,
            selector: #selector(requestContactsAccess),
            name: .requestContactsAccess, object: nil
        )
        self.center.addObserver(
            self,
            selector: #selector(requestRemindersAccess),
            name: .requestRemindersAccess, object: nil
        )

        self.center.addObserver(
            self,
            selector: #selector(updateAccess),
            name: .eventsAccessUpdated, object: nil
        )
        self.center.addObserver(
            self,
            selector: #selector(updateAccess),
            name: .contactsAccessUpdated, object: nil
        )
        self.center.addObserver(
            self,
            selector: #selector(updateAccess),
            name: .remindersAccessUpdated, object: nil
        )
    }

    private func removeObservers() {
        self.center.removeObserver(self, name: .requestAccess, object: nil)
        self.center.removeObserver(self, name: .requestEventsAccess, object: nil)
        self.center.removeObserver(self, name: .requestContactsAccess, object: nil)
        self.center.removeObserver(self, name: .requestRemindersAccess, object: nil)
        self.center.removeObserver(self, name: .eventsAccessUpdated, object: nil)
        self.center.removeObserver(self, name: .contactsAccessUpdated, object: nil)
        self.center.removeObserver(self, name: .remindersAccessUpdated, object: nil)
    }

}
