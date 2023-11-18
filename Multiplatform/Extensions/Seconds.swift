//
//  Seconds.swift
//  Cami
//
//  Created by Guillaume Coquard on 18/11/23.
//

import Foundation

extension Seconds {

    var days: Int {
        self / (24 * 3600)
    }

    var toDays: String {
        var component : DateComponents = DateComponents()
        component.day = self.days

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = .day
        formatter.unitsStyle = .abbreviated

        return formatter.string(from: component)!
    }
}
