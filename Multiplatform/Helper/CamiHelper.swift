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

    public static var allCalendars: Calendars {
        EventHelper.store.calendars(for: .event).filter { calendar in
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
        EventHelper.store.calendars(for: .event).first { calendar in
            calendar.type == .birthday
        }
    }

    public static func requestEventAccess() {
        PermissionModel.center.post(name: .requestCalendarsAccess, object: nil)
    }

    public static func requestReminderAccess() {
        PermissionModel.center.post(name: .requestRemindersAccess, object: nil)
    }

    public static func requestContactAccess() {
        PermissionModel.center.post(name: .requestContactsAccess, object: nil)
    }

    public static func requestAccess() {
        NotificationCenter.default.post(name: .requestAccess, object: nil)
    }

    public static func events(
        from calendars: Calendars = allCalendars,
        during days: Int = 30,
        where filter: ((EKEvent) -> Bool)? = nil,
        relativeTo date: Date
    ) -> EventDict {
        return EventHelper.events(
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
        return EventHelper.events(
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
        return EventHelper.birthdays(
            from: date,
            during: days
        )
    }

}
