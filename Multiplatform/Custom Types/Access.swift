//
//  Access.swift
//  Cami
//
//  Created by Guillaume Coquard on 11/02/24.
//

import Contacts
import EventKit
import Foundation

enum Access: CaseIterable, Hashable, Equatable {
    case calendars
    case contacts
    case reminders

    func request() async {
        switch self {
            case .calendars:
                await DataContext.shared.requestCalendarsAccess()
            case .contacts:
                await DataContext.shared.requestContactsAccess()
            case .reminders:
                await DataContext.shared.requestRemindersAccess()
        }
    }

    func retrieve() -> Status {
        switch self {
            case .calendars:
                Status(from: EKEventStore.authorizationStatus(for: .event))
            case .contacts:
                Status(from: CNContactStore.authorizationStatus(for: .contacts))
            case .reminders:
                Status(from: EKEventStore.authorizationStatus(for: .reminder))
        }
    }

    enum Status: CaseIterable, Hashable, Equatable {
        case none
        case notDetermined
        case restricted
        case authorized
    }
}

extension Access.Status {
    init(from status: EKAuthorizationStatus) {
        self = switch status {
            case .notDetermined: .notDetermined
            case .authorized, .fullAccess: .authorized
            default: .restricted
        }
    }
}

extension Access.Status {
    init(from status: CNAuthorizationStatus) {
        self = switch status {
            case .notDetermined: .notDetermined
            case .authorized: .authorized
            default: .restricted
        }
    }
}
