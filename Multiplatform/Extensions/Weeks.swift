//
//  Weeks.swift
//  Cami
//
//  Created by Guillaume Coquard on 22/11/23.
//

import Foundation

extension Weeks {
    func asDays() -> [Days] {
        map { $0.asDays() }
    }
}
