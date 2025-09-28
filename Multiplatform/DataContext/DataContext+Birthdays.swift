//
//  DataContext+Birthdays.swift
//  Cami
//
//  Created by Guillaume Coquard on 26/01/25.
//

import EventKit
import Foundation

// MARK: - Birthdays

// MARK: - Computed Properties - Birthdays

extension DataContext {
    var birthdayCalendar: EKCalendar? {
        _birthdayService.birthdayCalendar
    }

    var birthdays: [EKEvent] {
        _birthdayService.birthdays
    }

    func birthdays(from date: Date, during days: Int = 365) -> [EKEvent] {
        _birthdayService.birthdays(from: date, during: days)
    }
}
