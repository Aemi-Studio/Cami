//
//  EKEvent.swift
//  Cami
//
//  Created by Guillaume Coquard on 01/11/23.
//

import Foundation
import EventKit

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
        self.beginDate.isToday
    }

    var isEndingToday: Bool {
        self.endingDate.isToday
    }
}

extension CItem {

    func spansMore(than date: Date) -> Bool {
        let resetDate: Date = self.beginDate.zero
        let tomorrow: Date = Calendar.current.date(byAdding: DateComponents(day: 1), to: date)!
        return resetDate < date.zero || (self.isStartingToday && self.endingDate.zero > tomorrow)
    }

    func isSameDay(as event: EKEvent) -> Bool {
        let hasSameStartDate: Bool = self.beginDate.zero == event.beginDate.zero
        let hasSameEndDate: Bool = self.endingDate.zero == event.endingDate.zero
        return hasSameStartDate || hasSameEndDate
    }

    func isStrictlySameDay(as event: EKEvent) -> Bool {
        let hasSameStartDate: Bool = self.beginDate.zero == event.beginDate.zero
        let hasSameEndDate: Bool = self.endingDate.zero == event.endingDate.zero
        return hasSameStartDate && hasSameEndDate
    }

}

extension EKCalendarItem: @retroactive Identifiable {

    public var id: String {
        self.calendarItemIdentifier
    }

}
