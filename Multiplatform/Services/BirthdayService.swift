//
//  BirthdayService.swift
//  Cami
//
//  Created by Guillaume Coquard on 28/09/25.
//

import EventKit
import Foundation

final class BirthdayService: @unchecked Sendable {
    private let eventStoreService = EventStoreService.shared

    init() {}

    var birthdayCalendar: EKCalendar? {
        eventStoreService.store.calendars(for: .event).first { calendar in
            calendar.type == .birthday
        }
    }

    var birthdays: [EKEvent] {
        birthdays(from: .now, during: 90)
    }

    func birthdays(from date: Date, during days: Int = 365) -> [EKEvent] {
        guard let birthdayCalendar else {
            return []
        }

        let calendar = Calendar.autoupdatingCurrent

        var todayComponent = DateComponents()
        todayComponent.day = 0

        guard let today = calendar.date(byAdding: todayComponent, to: date, wrappingComponents: false)
        else {
            return [EKEvent]()
        }

        var limit = DateComponents()
        limit.day = days

        guard let endDate = calendar.date(byAdding: limit, to: date, wrappingComponents: false)
        else {
            return [EKEvent]()
        }

        let predicate = eventStoreService.store.predicateForEvents(withStart: today, end: endDate, calendars: [birthdayCalendar])

        return eventStoreService.store.events(matching: predicate).sorted(.orderedAscending)
    }
}
