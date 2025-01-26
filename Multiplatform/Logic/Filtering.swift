//
//  Filtering.swift
//  Cami
//
//  Created by Guillaume Coquard on 25/01/25.
//

import Foundation
import EventKit

protocol Filtering {
    func filter(item: EKCalendarItem) -> Bool
}

extension Filtering {
    func filter(item: EKCalendarItem) -> Bool {
        true
    }
}
