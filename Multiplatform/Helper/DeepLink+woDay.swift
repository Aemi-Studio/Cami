//
//  DeepLink+woDay.swift
//  Cami
//
//  Created by Guillaume Coquard on 23/01/25.
//

import Foundation

extension DataContext {
    @MainActor func openCalendarEvent(withId eventId: String) {
        if PermissionModel.shared.calendars == .authorized {
            if let event = event(for: eventId) {
                ViewModel.shared.path.append(event)
            }
        }
    }

    @MainActor func openCalendarDay(atTime timeInterval: String) {
        if PermissionModel.shared.calendars == .authorized {
            ViewModel.shared.path.append(Day(.init(timeIntervalSinceReferenceDate: TimeInterval(timeInterval)!)))
        }
    }
}
