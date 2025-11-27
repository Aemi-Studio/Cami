//
//  DataContext+Birthdays.swift
//  Cami
//
//  Created by Guillaume Coquard on 26/01/25.
//

import EventKit
import Foundation

// MARK: - Birthdays

extension DataContext {
    func birthdayCalendar() async -> EKCalendar? {
        await birthdayService.birthdayCalendar()
    }

    func birthdays() async -> [EKEvent] {
        await birthdayService.birthdays()
    }

    func birthdays(from date: Date, during days: Int = 365) async -> [EKEvent] {
        await birthdayService.birthdays(from: date, during: days)
    }
}
