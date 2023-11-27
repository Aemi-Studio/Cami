//
//  Dates.swift
//  Cami
//
//  Created by Guillaume Coquard on 22/11/23.
//

import Foundation

typealias Days          = [Day]

extension Date {

    func getDates(from component: Calendar.Component) -> Dates {
        switch component {
        case .month, .weekOfMonth, .weekOfYear:
            var dates: Dates = .init()
            let value: Int = self.get(component)
            var currentDay: Date = self.startOfMonth.zero
            repeat {
                dates.append(currentDay)
                // swiftlint:disable shorthand_operator
                currentDay = currentDay + DateComponents(day: 1)
                // swiftlint:enable shorthand_operator
            } while currentDay.get(component) == value
            return dates
        default:
            return Dates(arrayLiteral: self)
        }
    }

    func getDays(from component: Calendar.Component) -> Days {
        self.getDates(from: component).asDays()
    }
}

extension Dates {

    func sorted(_ order: ComparisonResult = .orderedAscending) -> Dates {
        self.sorted(by: { (first: Date, second: Date) in
            first.compare(second) == order
        })
    }

    var weeks: [Dates] {
        let dates: Dates = self.sorted(.orderedAscending)
        return dates.reduce(into: [Int: Dates]()) { dictionary, date in
            let week: Int = date.get(.weekOfYear)
            var currentDates: Dates
            if dictionary[week] != nil {
                currentDates = dictionary[week]!
                if currentDates.contains(where: { date.get(.weekday) == $0.get(.weekday) }) {
                    dictionary.updateValue([date], forKey: week + 1)
                } else {
                    currentDates.append(date)
                    dictionary.updateValue(currentDates, forKey: week)
                }
            } else {
                dictionary.updateValue([date], forKey: week)
            }
        }
        .map { (_, value) in value }
        .sorted { (first, second) in
            first.first!.compare(second.first!) == .orderedAscending
        }
    }

    func asDays() -> [Day] {
        self.map(Day.init)
    }

}
