//
//  CamiHelper.swift
//  Cami
//
//  Created by Guillaume Coquard on 15/11/23.
//

import Foundation
import EventKit
import Contacts

class CamiHelper {

    public static var eventStore: EKEventStore = EKEventStore()
    public static var contactStore: CNContactStore = CNContactStore()

    public static func authorizationStatus() -> AuthorizationSet {

        let calendarsAuthStatus: AuthSet = switch EKEventStore.authorizationStatus(for: .event) {
        case .fullAccess:
            AuthSet.calendars
        case .notDetermined:
            AuthSet.none
        default:
            AuthSet.restrictedCalendars
        }

        let remindersAuthStatus: AuthSet = switch EKEventStore.authorizationStatus(for: .reminder) {
        case .fullAccess:
            AuthSet.reminders
        case .notDetermined:
            AuthSet.none
        default:
            AuthSet.restrictedReminders
        }

        let contactsAuthStatus = switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            AuthSet.contacts
        case .notDetermined:
            AuthSet.none
        default:
            AuthSet.restrictedContacts
        }

        return AuthSet([
            calendarsAuthStatus,
            remindersAuthStatus,
            contactsAuthStatus
        ])

    }

    public static var allCalendars: CalendarList {
        self.eventStore.calendars(for: .event).filter { calendar in
            calendar.type != .birthday
        }
    }

    public static var birthdayCalendar: EKCalendar? {
        (self.eventStore.calendars(for: .event).first { calendar in
            calendar.type == .birthday
        })
    }

    public static func requestEventAccess() async -> AuthSet {
        await CalendarHelper.requestAccess(store: self.eventStore)
    }

    public static func requestReminderAccess() async -> AuthSet {
        await ReminderHelper.requestAccess(store: self.eventStore)
    }

    public static func requestContactAccess() async -> AuthSet {
        await ContactHelper.requestAccess(store: self.contactStore)
    }

    public static func requestAccess() async -> AuthSet {
        return AuthSet([
            await requestEventAccess(),
            await requestReminderAccess(),
            await requestContactAccess()
        ])
    }

    public static func events(
        calendars: [String] = allCalendars.asIdentifiers,
        days: Int = 30
    ) -> EventDict {
        return CalendarHelper.events(calendars: calendars, days: days)
    }

    public static func birthdays(days: Int = 365) -> EventList {
        return CalendarHelper.birthdays(days: days)
    }

}
