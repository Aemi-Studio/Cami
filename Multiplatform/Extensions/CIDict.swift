//
//  CIDict.swift
//  Cami
//
//  Created by Guillaume Coquard on 26/01/25.
//

import Foundation
import EventKit

extension CIDict {
    mutating func append(to date: Date, _ item: EKCalendarItem) {
        if self[date] != nil {
            self[date]!.append(item)
        } else {
            self[date] = [item]
        }
    }
}
