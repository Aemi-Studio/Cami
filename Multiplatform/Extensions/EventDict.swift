//
//  EventDict.swift
//  Cami
//
//  Created by Guillaume Coquard on 18/11/23.
//

import EventKit
import Foundation

extension [Date: [EKEvent]] {
    mutating func append(to date: Date, _ event: EKEvent) {
        if self[date] != nil {
            self[date]!.append(event)
        } else {
            self[date] = [event]
        }
    }
}
