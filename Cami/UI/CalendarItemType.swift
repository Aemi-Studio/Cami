//
//  CalendarItemType.swift
//  Cami
//
//  Created by Guillaume Coquard on 26.11.25.
//

import SwiftUI
import EventKit

enum CalendarItemType: CaseIterable {
    case event
    case reminder
}

@Observable
final class DayViewModel: Loggable {
    typealias UpdateAction = (CalendarItemType) -> Void

    var visibleTypes: Set<CalendarItemType> = Set(CalendarItemType.allCases)

    func filter(_ item: EKCalendarItem) -> Bool {
        switch item {
            case is EKEvent: visibleTypes.contains(.event)
            case is EKReminder: visibleTypes.contains(.reminder)
            default: false
        }
    }

    func bound(to type: CalendarItemType) -> Binding<Bool> {
        Binding {
            self.visibleTypes.contains(type)
        } set: { isOn in
            if isOn {
                self.visibleTypes.insert(type)
            } else {
                self.visibleTypes.remove(type)
            }
        }
    }
}
