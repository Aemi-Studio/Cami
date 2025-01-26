////
////  AuthorizationSet.swift
////  Cami
////
////  Created by Guillaume Coquard on 14/11/23.
////
//
// import Foundation
//
// struct PermissionSet: OptionSet, Loggable {
//
//    let rawValue: Int
//
//    static let calendars            = PermissionSet(rawValue: 1 << 0)
//    static let reminders            = PermissionSet(rawValue: 1 << 1)
//    static let contacts             = PermissionSet(rawValue: 1 << 2)
//
//    static let restrictedCalendars  = PermissionSet(rawValue: 1 << 3)
//    static let restrictedReminders  = PermissionSet(rawValue: 1 << 4)
//    static let restrictedContacts   = PermissionSet(rawValue: 1 << 5)
//
//    var status: PermissionStatus {
//        if !(self.isDisjoint(with: .authorized)) {
//            return .authorized
//        } else if !(self.isDisjoint(with: .restricted)) {
//            return .restricted
//        }
//        return .notDetermined
//    }
//
//    static private func opposite(_ member: PermissionSet) -> PermissionSet {
//        switch member {
//        case .calendars:
//            .restrictedCalendars
//        case .reminders:
//            .restrictedReminders
//        case .contacts:
//            .restrictedContacts
//        case .restrictedCalendars:
//            .calendars
//        case .restrictedReminders:
//            .reminders
//        case .restrictedContacts:
//            .contacts
//        default:
//            .none
//        }
//    }
//
//    mutating func insert(_ newMember: PermissionSet) {
//        let opposite: PermissionSet = PermissionSet.opposite(newMember)
//        self = self.contains(opposite)
//            ? self.symmetricDifference(opposite).union(newMember)
//            : self.union(newMember)
//    }
//
//    var calendars: PermissionSet {
//        self.intersection([.calendars, .restrictedCalendars])
//    }
//
//    var reminders: PermissionSet {
//        self.intersection([.reminders, .restrictedReminders])
//    }
//
//    var contacts: PermissionSet {
//        self.intersection([.contacts, .restrictedContacts])
//    }
//
//    static let restricted: PermissionSet = [
//        .restrictedCalendars,
//        .restrictedReminders,
//        .restrictedContacts
//    ]
//
//    static let all: PermissionSet = [
//        .calendars,
//        .contacts
//    ]
//
//    // swiftlint:disable identifier_name
//    static let _beta_all: PermissionSet = [
//        .calendars,
//        .reminders,
//        .contacts
//    ]
//    // swiftlint:enable identifier_name
//
//    static let authorized: PermissionSet = .all
//
//    // swiftlint:disable identifier_name
//    static let _beta_authorized: PermissionSet = ._beta_all
//    // swiftlint:enable identifier_name
//
//    static let none: PermissionSet = []
// }
