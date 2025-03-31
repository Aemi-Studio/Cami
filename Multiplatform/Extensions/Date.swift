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
        Calendar.autoupdatingCurrent.date(byAdding: rhs, to: lhs)!
    }

    static func + (lhs: DateComponents, rhs: Date) -> Date {
        Calendar.autoupdatingCurrent.date(byAdding: lhs, to: rhs)!
    }

    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
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
        Calendar.autoupdatingCurrent.isDateInToday(self)
    }
}

// MARK: Date Formatting

extension Date {
    enum FormatterKind {
        case short
        case medium
        case long
        case date
        case month
        case year

        private var formatter: DateFormatter {
            switch self {
                case .short: Date.formatter(DateFormatter.self) { $0.dateFormat = "EEEEE" }
                case .medium: Date.formatter(DateFormatter.self) { $0.dateFormat = "EEE" }
                case .long: Date.formatter(DateFormatter.self) { $0.dateFormat = "EEEE" }
                case .date: Date.formatter(DateFormatter.self) { $0.dateFormat = "d" }
                case .month: Date.formatter(DateFormatter.self) { $0.dateFormat = "MMMM" }
                case .year: Date.formatter(DateFormatter.self) { $0.dateFormat = "YYYY" }
            }
        }

        func callAsFunction(_ date: Date) -> String {
            formatter.string(from: date)
        }
    }

    private static func formatter<T: Formatter>(
        _ formatterType: T.Type,
        _ setup: @escaping (T) -> Void
    ) -> T {
        let outputFormatter = formatterType.init()
        setup(outputFormatter)
        return outputFormatter
    }

    var literals: [FormatterKind: String] {
        [
            .short: FormatterKind.short(self),
            .medium: FormatterKind.medium(self),
            .long: FormatterKind.long(self),
            .date: FormatterKind.date(self),
            .month: FormatterKind.month(self),
            .year: FormatterKind.year(self)
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

    var formattedUntilTomorrow: String {
        formatter {
            $0.dateStyle = .long
            $0.timeStyle = .none
            $0.doesRelativeDateFormatting = true
        }
    }

    var formattedAfterTomorrow: String {
        formatter { $0.dateFormat = "EEE d" }
            .capitalized(with: Locale(identifier: Locale.preferredLanguages.first!))
    }

    var relativeToNow: String {
        Self.formatter(RelativeDateTimeFormatter.self) {
            $0.locale = Locale(identifier: Locale.preferredLanguages.first!)
        }.string(for: self)!
    }

    func remainingTime(
        until date: Date,
        accuracy: NSCalendar.Unit = [.day, .hour, .minute]
    ) -> String {
        Self.formatter(DateComponentsFormatter.self) {
            $0.unitsStyle = .brief
            $0.zeroFormattingBehavior = .dropAll
            $0.allowedUnits = accuracy
        }.string(from: self, to: date)!
    }

    var formattedHour: String {
        formatter {
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
        calendar.dateComponents(Set(components), from: self)
    }

    func get(
        _ component: Calendar.Component,
        calendar: Calendar = Calendar.autoupdatingCurrent
    ) -> Int {
        calendar.component(component, from: self)
    }

    var startOfMonth: Date {
        Calendar.autoupdatingCurrent.date(
            from: get(.year, .month)
        )!.zero
    }

    var endOfPreviousMonth: Date {
        startOfMonth + DateComponents(day: -1)
    }

    var startOfPreviousMonth: Date {
        Calendar.autoupdatingCurrent.date(
            from: (get(.year, .month) + DateComponents(month: -1)).get(.year, .month)
        )!.zero
    }

    var endOfMonth: Date {
        Calendar.autoupdatingCurrent.date(
            byAdding: DateComponents(month: 1, day: -1),
            to: startOfMonth
        )!.zero
    }

    var startOfNextMonth: Date {
        Calendar.autoupdatingCurrent.date(
            from: (get(.year, .month) + DateComponents(month: 1)).get(.year, .month)
        )!.zero
    }

    var endOfNextMonth: Date {
        startOfNextMonth.endOfMonth
    }

    var startOfWeek: Date {
        Calendar.autoupdatingCurrent.date(
            from: get(.calendar, .yearForWeekOfYear, .weekOfYear)
        )!.zero
    }

    var endOfWeek: Date {
        Calendar.autoupdatingCurrent.date(
            byAdding: DateComponents(day: 6),
            to: startOfWeek
        )!.zero
    }

    func isSameMonth(as date: Date) -> Bool {
        get(.month) == date.get(.month)
    }

    func isSameWeek(as date: Date) -> Bool {
        get(.calendar, .yearForWeekOfYear, .weekOfYear) ==
            date.get(.calendar, .yearForWeekOfYear, .weekOfYear)
    }
}
