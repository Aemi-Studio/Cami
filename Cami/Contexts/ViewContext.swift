//
//  ViewContext.swift
//  Cami
//
//  Created by Guillaume Coquard on 20/11/23.
//

import Collections
import Contacts
import EventKit
import Foundation
import SwiftUI

@Observable
@MainActor final class ViewContext: Loggable {
    static let shared: ViewContext = .init(for: .now)

    private func generate(
        from startDate: Date,
        count: Int = 37,
        shift: Int = 0
    ) -> Deque<Month> {
        let fixedCount: Int = count % 2 == 0 ? count + 1 : count
        let startIndex: Int = -(fixedCount / 2) + shift
        let months = Deque<Month?>(repeating: nil, count: count)
        let newDate: Date = (startDate.startOfMonth + DateComponents(month: startIndex)).startOfMonth
        return months.reduce(into: [Month(newDate, id: startIndex)]) { result, _ in
            result.append(result.last!.next())
        }
    }

    public func reset() {
        calendars = Set(DataContext.shared.allCalendars.asIdentifiers)
        months = generate(from: date)
    }

    public var date: Date
    public var position: Int? = 0 {
        willSet {
            if newValue! > position! {
                months!.append(months!.last!.next())
            } else
            if newValue! < position! {
                months!.prepend(months!.first!.prev())
            }
        }
    }

    public var months: Deque<Month>?
    public var path: NavigationPath
    public var calendars: Set<String>

    public var weekdaysCount: Int {
        Calendar.autoupdatingCurrent.maximumRange(of: .weekday)!.count
    }

    private init(for date: Date, path: NavigationPath) {
        self.date = date
        self.path = path
        calendars = if PermissionContext.shared.global == .authorized {
            Set(DataContext.shared.allCalendars.asIdentifiers)
        } else {
            Set()
        }
        months = generate(from: date)
    }

    private init(for date: Date) {
        self.date = date
        path = NavigationPath()
        calendars = if PermissionContext.shared.global == .authorized {
            Set(DataContext.shared.allCalendars.asIdentifiers)
        } else {
            Set()
        }
        months = generate(from: date)
    }

    func generateNext(_ count: Int) {
        if (months?.count ?? 0) == 0 {
            months = [.init()]
            generateNext(count - 1)
        } else {
            for _ in 0 ..< count {
                months!.append(months!.last!.next())
            }
            //            self.months?.removeFirst(count)
        }
    }

    func generatePrevious(_ count: Int) {
        if (months?.count ?? 0) == 0 {
            months = [.init()]
            generatePrevious(count - 1)
        } else {
            for _ in 0 ..< count {
                months!.prepend(months!.first!.prev())
            }
            //            self.months?.removeLast(count)
        }
    }

    var first: Month {
        if (months?.count ?? 0) == 0 {
            months = [.init()]
        }
        return months!.first!
    }

    func removeFirst(_ count: Int) {
        months!.removeFirst(count)
    }

    func removeFirstUpTo(_ month: Month) {
        removeFirst(months!.count - (months!.firstIndex(of: month)! + 1))
    }

    func removeLastUpTo(_ month: Month) {
        removeLast(months!.count - (months!.lastIndex(of: month)! + 1))
    }

    func removeLast(_ count: Int) {
        months!.removeLast(count)
    }

    var last: Month {
        if (months?.count ?? 0) == 0 {
            months = [.init()]
        }
        return months!.last!
    }

    func first(id: Int) -> Month? {
        months?.first { $0.id == id }
    }

    func last(id: Int) -> Month? {
        months?.last { $0.id == id }
    }

    func first(where filter: @escaping (Month) throws -> Bool) rethrows -> Month? {
        try months?.first(where: filter)
    }

    func firstIndex(where filter: @escaping (Month) -> Bool) -> Int? {
        months?.firstIndex(where: filter)
    }

    func last(where filter: @escaping (Month) throws -> Bool) rethrows -> Month? {
        try months?.last(where: filter)
    }

    func lastIndex(where filter: @escaping (Month) -> Bool) -> Int? {
        months?.lastIndex(where: filter)
    }
}

private enum Side: Int {
    case prev = -1
    case next = 1
}

extension EnvironmentValues {
    @Entry var views: ViewContext!
}

class Month: Identifiable, Hashable {
    typealias ID = Int

    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
    }

    static func == (lhs: Month, rhs: Month) -> Bool {
        lhs.date == rhs.date
    }

    let id: ID
    let date: Date

    public func next() -> Month {
        Month(date.startOfNextMonth, prev: id)
    }

    public func prev() -> Month {
        Month(date.startOfPreviousMonth, next: id)
    }

    init(
        _ date: Date = Date.now.startOfMonth,
        prev: Month.ID? = nil,
        next: Month.ID? = nil,
        id: ID = 0
    ) {
        self.date = date
        if prev != nil {
            self.id = prev! + 1
        } else if next != nil {
            self.id = next! - 1
        } else {
            self.id = id
        }
    }
}
