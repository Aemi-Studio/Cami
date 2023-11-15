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
}
