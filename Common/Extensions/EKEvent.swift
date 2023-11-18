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
