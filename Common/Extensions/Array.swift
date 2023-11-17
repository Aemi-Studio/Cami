//
//  Array.swift
//  Cami
//
//  Created by Guillaume Coquard on 16/11/23.
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
