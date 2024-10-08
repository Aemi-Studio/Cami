//
//  Date.swift
//  Cami
//
//  Created by Guillaume Coquard on 01/11/23.
//

import Foundation

// MARK: Operators
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

// MARK: Basics
extension Date {

    /// Same date but at midnight
    var zero: Date {
        Calendar.autoupdatingCurrent.startOfDay(for: self)
    }

    /// Is the date of the same day as today
    var isToday: Bool {
        self.zero == Date.now.zero
    }

}

// MARK: Date Formatting
extension Date {

    var literals: [String: String] {
        [
            "short": self.formatter { $0.dateFormat = "EEEEE" },
            "medium": self.formatter { $0.dateFormat = "EEE" },
            "long": self.formatter { $0.dateFormat = "EEEE" },
            "date": self.formatter { $0.dateFormat = "d"    },
            "month": self.formatter { $0.dateFormat = "MMMM" },
            "year": self.formatter { $0.dateFormat = "YYYY" }
        ]
    }

    func formatter(
        _ setup: @escaping (DateFormatter) -> Void
    ) -> String {
        let formatter: DateFormatter = .init()
        formatter.locale = Locale(identifier: Locale.preferredLanguages.first!)
        setup(formatter)
        return formatter.string(from: self)
    }

    func formatter<T: Formatter>(
        _ formatterType: T.Type,
        _ setup: @escaping (T) -> Void
    ) -> T {
        let outputFormatter = formatterType.init()
        setup(outputFormatter)
        return outputFormatter
    }

    var formattedUntilTomorrow: String {
        self.formatter {
            $0.dateStyle = .long
            $0.timeStyle = .none
            $0.doesRelativeDateFormatting = true
        }
    }

    var formattedAfterTomorrow: String {
        self.formatter { $0.dateFormat = "EEE d" }
            .capitalized(with: Locale(identifier: Locale.preferredLanguages.first!))
    }

    var relativeToNow: String {
        self.formatter(RelativeDateTimeFormatter.self) {
            $0.locale = Locale(identifier: Locale.preferredLanguages.first!)
        }.string(for: self)!
    }

    func remainingTime(
        until date: Date,
        accuracy: NSCalendar.Unit = [.day, .hour, .minute]
    ) -> String {
        self.formatter(DateComponentsFormatter.self) {
            $0.unitsStyle = .brief
            $0.zeroFormattingBehavior = .dropAll
            $0.allowedUnits = accuracy
        }.string(from: self, to: date)!
    }

    var formattedHour: String {
        self.formatter {
            $0.dateStyle = .none
            $0.timeStyle = .short
            $0.formattingContext = .standalone
        }
    }

}

// MARK: Useful
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
            from: self.get(.year, .month)
        )!.zero
    }

    var endOfPreviousMonth: Date {
        self.startOfMonth + DateComponents(day: -1)
    }

    var startOfPreviousMonth: Date {
        Calendar.autoupdatingCurrent.date(
            from: (self.get(.year, .month) + DateComponents(month: -1)).get(.year, .month)
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
            from: (self.get(.year, .month) + DateComponents(month: 1)).get(.year, .month)
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
