//
//  EKCalendarItem.swift
//  Cami
//
//  Created by Guillaume Coquard on 01/11/23.
//

import EventKit
import Foundation

extension CItem {
    // swiftlint:disable force_cast
    var beginDate: Date {
        switch self {
        case is EKEvent:
            return (self as! EKEvent).startDate
        case is EKReminder:
            return (self as! EKReminder).startDateComponents?.date ?? (self as! EKReminder).creationDate ?? Date()
        default:
            return Date()
        }
    }

    var endingDate: Date {
        switch self {
        case is EKEvent:
            return (self as! EKEvent).endDate
        case is EKReminder:
            return (self as! EKReminder).completionDate ?? (self as! EKReminder).dueDateComponents?.date ?? Date()
        default:
            return Date()
        }
    }

    // swiftlint:enable force_cast

    var isStartingToday: Bool {
        beginDate.isToday
    }

    var isEndingToday: Bool {
        endingDate.isToday
    }
}

extension CItem {
    func spansMore(than date: Date) -> Bool {
        let resetDate: Date = beginDate.zero
        let tomorrow: Date = Calendar.current.date(byAdding: DateComponents(day: 1), to: date)!
        return resetDate < date.zero || (isStartingToday && endingDate.zero > tomorrow)
    }

    func isSameDay(as event: EKEvent) -> Bool {
        let hasSameStartDate: Bool = beginDate.zero == event.beginDate.zero
        let hasSameEndDate: Bool = endingDate.zero == event.endingDate.zero
        return hasSameStartDate || hasSameEndDate
    }

    func isStrictlySameDay(as event: EKEvent) -> Bool {
        let hasSameStartDate: Bool = beginDate.zero == event.beginDate.zero
        let hasSameEndDate: Bool = endingDate.zero == event.endingDate.zero
        return hasSameStartDate && hasSameEndDate
    }
}

extension EKCalendarItem: @retroactive Identifiable {
    public var id: String {
        calendarItemIdentifier
    }
}
