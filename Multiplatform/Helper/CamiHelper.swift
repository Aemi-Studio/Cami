//
//  CamiHelper.swift
//  Cami
//
//  Created by Guillaume Coquard on 15/11/23.
//

import Foundation
import EventKit
import Contacts

struct CamiHelper {

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

    public static var allCalendars: Calendars {
        self.eventStore.calendars(for: .event).filter { calendar in
            calendar.type != .birthday
        }
    }

    public static var calendarColors: [String: CGColor] {
        allCalendars.reduce(into: [String: CGColor]()) { (result, calendar) in
            if let color = calendar.cgColor {
                result[calendar.calendarIdentifier] = color
            }
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
        from calendars: Calendars = allCalendars,
        during days: Int = 30,
        where filter: ((EKEvent) -> Bool)? = nil,
        relativeTo date: Date
    ) -> EventDict {
        return CalendarHelper.events(
            from: calendars,
            during: days,
            where: filter,
            relativeTo: date
        ).mapped(
            relativeTo: date
        )
    }

    public static func events(
        from calendars: [String] = allCalendars.asIdentifiers,
        during days: Int = 30,
        where filter: ((EKEvent) -> Bool)? = nil,
        relativeTo date: Date
    ) -> EventDict {
        return CalendarHelper.events(
            from: calendars,
            during: days,
            where: filter,
            relativeTo: date
        ).mapped(
            relativeTo: date
        )
    }

    public static func events(
        from calendars: [WidgetCalendarEntity] = WidgetCalendarEntity.allCalendars,
        during days: Int = 30,
        where filter: ((EKEvent) -> Bool)? = nil,
        relativeTo date: Date
    ) -> EventDict {
        return self.events(
            from: calendars.map { $0.calendar },
            during: days,
            where: filter,
            relativeTo: date
        )
    }

    public static func birthdays(
        from date: Date,
        during days: Int = 365
    ) -> Events {
        return CalendarHelper.birthdays(
            from: date,
            during: days
        )
    }

}
