//
//  BirthdayService.swift
//  Cami
//
//  Created by Guillaume Coquard on 28/09/25.
//

import EventKit
import Foundation

/// Service for fetching birthday events from the calendar.
@MainActor
final class BirthdayService {
    private let eventStoreService = EventStoreService.shared

    init() {}

    func birthdayCalendar() async -> EKCalendar? {
        await eventStoreService.store.calendars(for: .event).first { calendar in
            calendar.type == .birthday
        }
    }

    func birthdays() async -> [EKEvent] {
        await birthdays(from: .now, during: 90)
    }

    func birthdays(from date: Date, during days: Int = 365) async -> [EKEvent] {
        guard let birthdayCalendar = await birthdayCalendar() else {
            return []
        }

        let calendar = Calendar.autoupdatingCurrent

        var todayComponent = DateComponents()
        todayComponent.day = 0

        guard let today = calendar.date(byAdding: todayComponent, to: date, wrappingComponents: false)
        else {
            return []
        }

        var limit = DateComponents()
        limit.day = days

        guard let endDate = calendar.date(byAdding: limit, to: date, wrappingComponents: false)
        else {
            return []
        }

        let store = await eventStoreService.store
        let predicate = store.predicateForEvents(
            withStart: today,
            end: endDate,
            calendars: [birthdayCalendar]
        )

        return store.events(matching: predicate).sorted(.orderedAscending)
    }
}
