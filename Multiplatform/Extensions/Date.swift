//
//  Date.swift
//  Cami
//
//  Created by Guillaume Coquard on 01/11/23.
//

import Foundation

//MARK: Operators
extension Date {

    static func + (lhs: Date, rhs: DateComponents) -> Date {
        return Calendar.autoupdatingCurrent.date(byAdding: rhs, to: lhs)!
    }
    
    static func + (lhs: DateComponents, rhs: Date) -> Date {
        return Calendar.autoupdatingCurrent.date(byAdding: lhs, to: rhs)!
    }
    
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

}

//MARK: Basics
extension Date {

    /// Same date but at midnight
    var zero: Date {
        Calendar.autoupdatingCurrent.date(
            bySettingHour: 0,
            minute: 0,
            second: 0,
            of: self
        )!
    }

    /// Is the date of the same day as today
    var isToday: Bool {
        self.zero == Date.now.zero
    }

}

// MARK: Date Formatting
extension Date {

    var literals: (name: String, number: String) {
        let stringFormatter = DateFormatter()
        let numberFormatter = DateFormatter()
        stringFormatter.locale = Locale.autoupdatingCurrent
        numberFormatter.locale = Locale.autoupdatingCurrent
        stringFormatter.dateFormat = "EEEE"
        numberFormatter.dateFormat = "d"
        return (
            name: stringFormatter.string(from: self),
            number: numberFormatter.string(from: self)
        )
    }

    var formattedUntilTomorrow: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.doesRelativeDateFormatting = true
        formatter.locale = Locale.autoupdatingCurrent
        return formatter.string(from: self)
    }

    var formattedAfterTomorrow: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE d"
        formatter.locale = Locale.autoupdatingCurrent
        return formatter.string(from: self)
    }

    var relativeToNow: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale.autoupdatingCurrent
        return formatter.string(for: self)!
    }

    func remainingTime(until date: Date, accuracy: NSCalendar.Unit = [.day,.hour,.minute]) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        formatter.allowedUnits = accuracy
        return formatter.string(from: self, to: date)!
    }

}

//MARK: Useful
extension Date {

    func get(
        _ components: Calendar.Component...,
        calendar: Calendar = Calendar.autoupdatingCurrent
    ) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(
        _ component: Calendar.Component,
        calendar: Calendar = Calendar.autoupdatingCurrent
    ) -> Int {
        return calendar.component(component, from: self)
    }

    var startOfMonth: Date {
        Calendar.autoupdatingCurrent.date(
            from: self.get(.year,.month)
        )!.zero
    }

    var endOfPreviousMonth: Date {
        self.startOfMonth + DateComponents(day: -1)
    }

    var startOfPreviousMonth: Date {
        Calendar.autoupdatingCurrent.date(
            from: (self.get(.year,.month) + DateComponents(month: -1)).get(.year,.month)
        )!.zero
    }

    var endOfMonth: Date {
        Calendar.autoupdatingCurrent.date(
            byAdding: DateComponents(month: 1, day: -1),
            to: self.startOfMonth
        )!.zero
    }

    var startOfNextMonth: Date {
        Calendar.autoupdatingCurrent.date(
            from: (self.get(.year,.month) + DateComponents(month: 1)).get(.year,.month)
        )!.zero
    }

    var endOfNextMonth: Date {
        self.startOfNextMonth.endOfMonth
    }

    var startOfWeek: Date {
        Calendar.autoupdatingCurrent.date(
            from: self.get(.calendar, .yearForWeekOfYear, .weekOfYear)
        )!.zero
    }

    var endOfWeek: Date {
        Calendar.autoupdatingCurrent.date(
            byAdding: DateComponents(day: 6),
            to: self.startOfWeek
        )!.zero
    }

    func isSameMonth(as date: Date) -> Bool {
        self.get(.month) == date.get(.month)
    }

    func isSameWeek(as date: Date) -> Bool {
        self.get(.calendar, .yearForWeekOfYear, .weekOfYear) ==
        date.get(.calendar, .yearForWeekOfYear, .weekOfYear)
    }

}
