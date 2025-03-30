//
//  StandardWidgetConfiguration.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 18/11/23.
//

import SwiftUI

@Observable
final class StandardWidgetConfiguration {
    private(set) var allDayStyle: AllDayStyleEnum
    private(set) var complication: ComplicationEnum
    private(set) var showReminders: Bool
    private(set) var showHeader: Bool
    private(set) var useUnifiedList: Bool
    private(set) var showOngoingEvents: Bool
    private(set) var groupEvents: Bool

    init() {
        allDayStyle = .event
        complication = .birthdays
        showHeader = true
        showReminders = true
        useUnifiedList = true
        showOngoingEvents = true
        groupEvents = true
    }

    init(from intent: CamiWidgetIntent) {
        allDayStyle = intent.allDayStyle
        complication = intent.complication
        showHeader = intent.showHeader
        showReminders = intent.reminders
        useUnifiedList = intent.useUnifiedList
        showOngoingEvents = intent.ongoingEvents
        groupEvents = intent.groupEvents
    }
}

extension StandardWidgetConfiguration {
    static let `default` = StandardWidgetConfiguration()
}


extension Observable {
    func binding<T>(for path: KeyPath<Self,T>) -> Binding<T> {
        var this = self
        return Binding {
            this[keyPath: path]
        } set: { value in
            if let path = path as? WritableKeyPath<Self, T> {
                this[keyPath: path] = value
            }
        }
    }
}
