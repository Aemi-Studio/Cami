//
//  DataContext+Events.swift
//  Cami
//
//  Created by Guillaume Coquard on 26/01/25.
//

import EventKit
import Foundation

// MARK: - Events

extension DataContext {
    func event(for id: String) -> EKEvent? {
        _eventService.event(for: id)
    }

    func events(
        from calendars: [EKCalendar]? = nil,
        during days: Int,
        where filter: ((EKEvent) -> Bool) = { _ in true },
        relativeTo date: Date
    ) -> [EKEvent] {
        let calendars = calendars ?? self.calendars
        return _eventService.events(from: calendars, during: days, where: filter, relativeTo: date)
    }

    func events(
        from calendars: [EKCalendar],
        limit count: Int = Int.max,
        where filter: ((EKEvent) -> Bool) = { _ in true },
        relativeTo date: Date
    ) -> [EKEvent] {
        return _eventService.events(from: calendars, limit: count, where: filter, relativeTo: date)
    }

    func events(
        from calendars: [String],
        during days: Int = 30,
        where filter: ((EKEvent) -> Bool) = { _ in true },
        relativeTo date: Date
    ) -> [EKEvent] {
        return _eventService.events(from: calendars, during: days, where: filter, relativeTo: date)
    }
}
