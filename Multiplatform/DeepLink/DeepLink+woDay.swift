//
//  DeepLink+woDay.swift
//  Cami
//
//  Created by Guillaume Coquard on 23/01/25.
//

import Foundation

@MainActor
extension DataContext {
    func openCalendarEvent(withId eventId: String) {
        if PermissionContext.shared.calendars == .authorized {
            if let event = event(for: eventId) {
                UIContext.shared.path.append(event)
            }
        }
    }

    func openCalendarDay(atTime timeInterval: String) {
        if PermissionContext.shared.calendars == .authorized {
            UIContext.shared.path.append(Date(timeIntervalSinceReferenceDate: TimeInterval(timeInterval)!))
        }
    }

    func openCreationFlow() {
        if PermissionContext.shared.calendars == .authorized || PermissionContext.shared.reminders == .authorized {
            PresentationContext.shared.toggleMenu(.new())
        }
    }
}
