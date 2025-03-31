//
//  Events.swift
//  Cami
//
//  Created by Guillaume Coquard on 17/11/23.
//

import EventKit
import Foundation
import SwiftUI

extension Collection<EKEvent> {
    func sorted(_ order: ComparisonResult = .orderedAscending) -> [Element] {
        sorted(by: { first, second in
            switch order {
                case .orderedAscending: first.startDate < second.startDate
                case .orderedDescending: first.startDate > second.startDate
                case .orderedSame: first.startDate == second.startDate
            }
        })
    }
}
