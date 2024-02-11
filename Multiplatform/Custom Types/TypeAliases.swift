//
//  Types.swift
//  Cami
//
//  Created by Guillaume Coquard on 07/11/23.
//

import EventKit

typealias Calendars     = [EKCalendar]
typealias Events        = [EKEvent]
typealias EventDict     = [Date: [EKEvent]]
typealias Dates         = [Date]
typealias Weeks         = [Dates]

typealias Birthdays     = Events
typealias AuthSet       = PermissionSet
typealias Seconds       = Int

typealias DateRange     = ClosedRange<Date>
typealias DateStride    = StrideTo<Date>
