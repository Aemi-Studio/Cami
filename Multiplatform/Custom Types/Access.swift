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

    var status: Status {
        retrieve()
    }

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
            .init(from: EKEventStore.authorizationStatus(for: .event))
        case .contacts:
            .init(from: CNContactStore.authorizationStatus(for: .contacts))
        case .reminders:
            .init(from: EKEventStore.authorizationStatus(for: .reminder))
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
