//
//  AuthorizationSet.swift
//  Cami
//
//  Created by Guillaume Coquard on 14/11/23.
//

import Foundation

struct AuthorizationSet: OptionSet {

    let rawValue: Int

    enum Status: Int {
        case authorized = 1
        case restricted = 0
        case notDetermined = -1
    }

    static let calendars            = AuthorizationSet(rawValue: 1 << 0)
    static let reminders            = AuthorizationSet(rawValue: 1 << 1)
    static let contacts             = AuthorizationSet(rawValue: 1 << 2)

    static let restrictedCalendars  = AuthorizationSet(rawValue: 1 << 3)
    static let restrictedReminders  = AuthorizationSet(rawValue: 1 << 4)
    static let restrictedContacts   = AuthorizationSet(rawValue: 1 << 5)

    var status: Status {
        if !(self.intersection(.all).isEmpty) {
            return .authorized
        }
        else if !(self.intersection(.restricted).isEmpty) {
            return .restricted
        }
        return .notDetermined
    }

    static private func opposite(_ member: AuthorizationSet) -> AuthorizationSet {
        switch member {
            case .calendars:
                    .restrictedCalendars
            case .reminders:
                    .restrictedReminders
            case .contacts:
                    .restrictedContacts
            case .restrictedCalendars:
                    .calendars
            case .restrictedReminders:
                    .reminders
            case .restrictedContacts:
                    .contacts
            default:
                    .none
        }
    }

    mutating func insert(_ newMember: AuthorizationSet) {
        let opposite: AuthorizationSet = AuthorizationSet.opposite(newMember)
        self = self.contains(opposite)
        ? self.symmetricDifference(opposite).union(newMember)
        : self.union(newMember)
    }

    var calendars: AuthorizationSet {
        self.intersection([.calendars,.restrictedCalendars])
    }

    var reminders: AuthorizationSet {
        self.intersection([.reminders,.restrictedReminders])
    }

    var contacts: AuthorizationSet {
        self.intersection([.contacts,.restrictedContacts])
    }

    private static let restricted: AuthorizationSet = [
        .restrictedCalendars,
        .restrictedReminders,
        .restrictedContacts
    ]

    static let all: AuthorizationSet = [
        .calendars,
        .reminders,
        .contacts
    ]

    static let none: AuthorizationSet = []
}
