//
//  Types.swift
//  Cami
//
//  Created by Guillaume Coquard on 07/11/23.
//

import EventKit

typealias Calendars     = [EKCalendar]
typealias TaskLists     = [EKCalendar]
typealias Events        = [EKEvent]
typealias Reminders     = [EKReminder]
typealias CItems        = [EKCalendarItem]
typealias EventDict     = [Date: [EKEvent]]
typealias CIDict        = [Date: [EKCalendarItem]]
typealias Dates         = [Date]
typealias Weeks         = [Dates]

typealias CItem         = EKCalendarItem

typealias Birthdays     = Events
typealias Seconds       = Int

typealias DateRange     = ClosedRange<Date>
typealias DateStride    = StrideTo<Date>
