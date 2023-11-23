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
                let _component: Int = self.get(component)
                var currentDay: Date = self.startOfMonth.zero
                repeat {
                    dates.append(currentDay)
                    currentDay = currentDay + DateComponents(day: 1)
                } while currentDay.get(component) == _component
                return dates
            default:
                return Dates(arrayLiteral:self)
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
            var _dates: Dates
            if dictionary[week] != nil {
                _dates = dictionary[week]!
                if _dates.contains(where: { date.get(.weekday) == $0.get(.weekday) }) {
                    dictionary.updateValue([date], forKey: week + 1)
                } else {
                    _dates.append(date)
                    dictionary.updateValue(_dates, forKey: week)
                }
            } else {
                dictionary.updateValue([date], forKey: week)
            }
        }
        .map { (key,value) in value }
        .sorted { (first,second) in
            first.first!.compare(second.first!) == .orderedAscending
        }
    }

    func asDays() -> [Day] {
        self.map(Day.init)
    }

}
