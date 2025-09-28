//
//  DeepLink+woDay.swift
//  Cami
//
//  Created by Guillaume Coquard on 23/01/25.
//

import Foundation

@MainActor
extension DataContext {
    func openCalendarEvent(withId eventId: String, manager: PermissionManager) {
        if manager.calendarStatus == .authorized {
            if let event = event(for: eventId) {
                UIContext.shared.path.append(event)
            }
        }
    }

    func openCalendarDay(atTime timeInterval: String, manager: PermissionManager) {
        if manager.calendarStatus == .authorized {
            UIContext.shared.path.append(Date(timeIntervalSinceReferenceDate: TimeInterval(timeInterval)!))
        }
    }
}
