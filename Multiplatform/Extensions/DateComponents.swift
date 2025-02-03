//
//  DateComponents.swift
//  Cami
//
//  Created by Guillaume Coquard on 21/11/23.
//

import Foundation

extension DateComponents {
    static func + (lhs: DateComponents, rhs: DateComponents) -> Date {
        Calendar.autoupdatingCurrent.date(from: lhs)! + rhs
    }

    var yearsAgo: Int {
        Date().get(.year) - (year ?? 0)!
    }
}
