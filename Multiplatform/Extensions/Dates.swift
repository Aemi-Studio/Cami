//
//  [Date].swift
//  Cami
//
//  Created by Guillaume Coquard on 22/11/23.
//

import Foundation

extension Date {
    func getDates(from component: Calendar.Component) -> [Date] {
        switch component {
            case .month, .weekOfMonth, .weekOfYear:
                var dates: [Date] = .init()
                let value: Int = get(component)
                var currentDay: Date = startOfMonth.zero
                repeat {
                    dates.append(currentDay)
                    // swiftlint:disable shorthand_operator
                    currentDay = currentDay + DateComponents(day: 1)
                    // swiftlint:enable shorthand_operator
                } while currentDay.get(component) == value
                return dates
            default:
                return [Date](arrayLiteral: self)
        }
    }
}

extension [Date] {
    func sorted(_ order: ComparisonResult = .orderedAscending) -> [Date] {
        sorted(by: { (first: Date, second: Date) in
            first.compare(second) == order
        })
    }

    var weeks: [[Date]] {
        let dates: [Date] = sorted(.orderedAscending)
        return dates.reduce(into: [Int: [Date]]()) { dictionary, date in
            let week: Int = date.get(.weekOfYear)
            var currentDates: [Date]
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
        .map { _, value in value }
        .sorted { first, second in
            first.first!.compare(second.first!) == .orderedAscending
        }
    }
}
