//
//  EventDict.swift
//  Cami
//
//  Created by Guillaume Coquard on 18/11/23.
//

import Foundation
import EventKit

extension EventDict {
    mutating func append(to date: Date, _ event: EKEvent) {
        if self[date] != nil {
            self[date]!.append(event)
        } else {
            self[date] = [event]
        }
    }

}
