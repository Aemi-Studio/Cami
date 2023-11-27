//
//  EKEvent.swift
//  Cami
//
//  Created by Guillaume Coquard on 01/11/23.
//

import Foundation
import EventKit

extension EKEvent {

    var isStartingToday: Bool {
        self.startDate.isToday
    }

    var isEndingToday: Bool {
        self.endDate.isToday
    }

    func spansMore(than date: Date) -> Bool {
        let resetDate: Date = self.startDate.zero
        let tomorrow: Date = Calendar.current.date(byAdding: DateComponents(day: 1), to: date)!
        return resetDate < date.zero || (self.isStartingToday && self.endDate.zero > tomorrow)
    }

    func isSameDay(as event: EKEvent) -> Bool {
        let hasSameStartDate: Bool = self.startDate.zero == event.startDate.zero
        let hasSameEndDate: Bool = self.endDate.zero == event.endDate.zero
        return hasSameStartDate || hasSameEndDate
    }

    func isStrictlySameDay(as event: EKEvent) -> Bool {
        let hasSameStartDate: Bool = self.startDate.zero == event.startDate.zero
        let hasSameEndDate: Bool = self.endDate.zero == event.endDate.zero
        return hasSameStartDate && hasSameEndDate
    }

}
