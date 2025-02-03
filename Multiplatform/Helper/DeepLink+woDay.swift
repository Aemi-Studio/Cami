//
//  DeepLink+woDay.swift
//  Cami
//
//  Created by Guillaume Coquard on 23/01/25.
//

import Foundation

extension DataContext {
    @MainActor func openCalendarEvent(withId eventId: String) {
        if PermissionContext.shared.calendars == .authorized {
            if let event = event(for: eventId) {
                ViewContext.shared.path.append(event)
            }
        }
    }

    @MainActor func openCalendarDay(atTime timeInterval: String) {
        if PermissionContext.shared.calendars == .authorized {
            ViewContext.shared.path.append(Day(.init(timeIntervalSinceReferenceDate: TimeInterval(timeInterval)!)))
        }
    }
}
