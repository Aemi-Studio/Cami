//
//  Days.swift
//  Cami
//
//  Created by Guillaume Coquard on 16/11/23.
//

import Foundation

extension Days {
    var toDays: String {
        var component : DateComponents = DateComponents()
        component.day = self

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = .day
        formatter.unitsStyle = .abbreviated

        return formatter.string(from: component)!
    }
}
