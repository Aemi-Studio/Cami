//
//  EKEventExtension.swift
//  Cami
//
//  Created by Guillaume Coquard on 01/11/23.
//

import Foundation
import EventKit

extension Array {
    /// An array of events sorted by start date in ascending order.
    func sortedEventByAscendingDate() -> [EKEvent] {
        guard let self = self as? [EKEvent] else { return [] }

        return self.sorted(by: { (first: EKEvent, second: EKEvent) in
            return first.compareStartDate(with: second) == .orderedAscending
        })
    }
}


extension EKEvent {

    var isStartingToday: Bool {
        self.startDate.zero == Date.now.zero
    }

    var isEndingToday: Bool {
        self.endDate.zero == Date.now.zero
    }

    func isSameDayAs(event: EKEvent) -> Bool {
        let hasSameStartDate: Bool = self.startDate.zero == event.startDate.zero
        let hasSameEndDate: Bool = self.endDate.zero == event.endDate.zero
        return hasSameStartDate && hasSameEndDate
    }
}
