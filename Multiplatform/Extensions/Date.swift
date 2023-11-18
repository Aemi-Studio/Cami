//
//  Date.swift
//  Cami
//
//  Created by Guillaume Coquard on 01/11/23.
//

import Foundation

extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}

extension Date {

    var literals: (name: String, number: String) {
        let stringFormatter = DateFormatter()
        let numberFormatter = DateFormatter()
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
        return formatter.string(from: self)
    }

    var formattedAfterTomorrow: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE d"
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

    var zero: Date {
        Calendar.current.date(
            bySettingHour: 0,
            minute: 0,
            second: 0,
            of: self
        )!
    }

    var isToday: Bool {
        self.zero == Date.now.zero
    }

    /// The day of the week matching the specified date.
    var matchingDay: Int {
        Calendar.current.component(.weekday, from: self)
    }

    /// The next date for the given weekdays.
    func fetchNextDateFromDays(_ nextWeekDay: IndexSet) -> Date {
        var components: Int?
        let weekDay = Calendar.current.component(.weekday, from: self)

        if let nextWeekDay = nextWeekDay.integerGreaterThan(weekDay) {
            components = nextWeekDay
        } else {
            components = nextWeekDay.first
        }
        guard let foundWeekDay = components else { return self }
        return Calendar.current.nextDate(after: self, matching: DateComponents(weekday: foundWeekDay), matchingPolicy: .nextTime) ?? self
    }

    /// The formatted time of the date.
    var timeAsText: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    /// Thirty minutes from the current time.
    var thirtyMinutesLater: Date {
        Date(timeInterval: 1800, since: self)
    }

    /// A month from the current date.
    var oneMonthOut: Date {
        Calendar.current.date(byAdding: .month, value: 1, to: Date.now) ?? Date()
    }

    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}
