//
//  EKAuthorizationSet.swift
//  Cami
//
//  Created by Guillaume Coquard on 14/11/23.
//

import Foundation

struct EKAuthorizationSet: OptionSet {
    let rawValue: Int

    static let events = EKAuthorizationSet(rawValue: 1 << 0)
    static let reminders  = EKAuthorizationSet(rawValue: 1 << 1)

    static let both: EKAuthorizationSet = [.events,.reminders]
    static let none: EKAuthorizationSet = []
}
