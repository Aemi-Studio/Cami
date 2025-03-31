//
//  PermissionContext.swift
//  Cami
//
//  Created by Guillaume Coquard on 10/02/24.
//

import Combine
import Contacts
import EventKit
import SwiftUI

@Observable
final class PermissionContext: Loggable {
    static let shared: PermissionContext = .init()

    private let accesses: [Access] = [.calendars, .contacts, .reminders]

    private(set) var calendars: Access.Status = .none
    private(set) var contacts: Access.Status = .none
    private(set) var reminders: Access.Status = .none

    var global: Access.Status {
        if [calendars, contacts, reminders].allSatisfy({ $0 == .authorized }) {
            .authorized
        } else if [calendars, contacts, reminders].contains(.restricted) {
            .restricted
        } else {
            .notDetermined
        }
    }

    init() {
        update()
    }
}

extension PermissionContext {
    func update(access: Access) {
        withAnimation {
            switch access {
                case .calendars: self.calendars = access.retrieve()
                case .contacts: self.contacts = access.retrieve()
                case .reminders: self.reminders = access.retrieve()
            }
        }
    }

    func request(access: Access) async {
        switch access {
            case .calendars: await access.request()
            case .contacts: await access.request()
            case .reminders: await access.request()
        }
        update()
    }

    func update() {
        for access in accesses {
            update(access: access)
        }
    }

    func request() async {
        for access in accesses {
            await access.request()
        }
        update()
    }

    func reset() {
        #if DEBUG
            calendars = .none
            contacts = .none
            reminders = .none
        #endif
    }
}

extension EnvironmentValues {
    @Entry var permissions: PermissionContext = .shared
}
