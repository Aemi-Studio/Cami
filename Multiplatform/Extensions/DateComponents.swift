//
//  DateComponents.swift
//  Cami
//
//  Created by Guillaume Coquard on 16/11/23.
//

import Foundation

extension DateComponents {
    var yearsAgo: Int {
        return Date().get(.year) - (self.year ?? 0)!
    }
}
