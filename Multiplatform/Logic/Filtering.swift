//
//  Filtering.swift
//  Cami
//
//  Created by Guillaume Coquard on 25/01/25.
//

import EventKit
import Foundation

protocol Filtering {
    func filter(item: EKCalendarItem) -> Bool
}

extension Filtering {
    func filter(item _: EKCalendarItem) -> Bool {
        true
    }
}
