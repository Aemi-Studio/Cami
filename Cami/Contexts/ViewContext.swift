//
//  ViewContext.swift
//  Cami
//
//  Created by Guillaume Coquard on 20/11/23.
//

import Foundation
import SwiftUI
import Collections
import EventKit
import Contacts

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
        let months: Deque<Month?> = Deque<Month?>(repeating: nil, count: count)
        let newDate: Date = (startDate.startOfMonth + DateComponents(month: startIndex)).startOfMonth
        return months.reduce(into: [Month(newDate, id: startIndex)], { result, _ in
            result.append(result.last!.next())
        })
    }

    public func reset() {
        self.calendars = Set(DataContext.shared.allCalendars.asIdentifiers)
        self.months = self.generate(from: self.date)
    }

    public var date: Date
    public var position: Int? = 0 {
        willSet {
            if newValue! > self.position! {
                self.months!.append(self.months!.last!.next())
            } else
            if newValue! < self.position! {
                self.months!.prepend(self.months!.first!.prev())
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
        self.calendars = if PermissionContext.shared.global == .authorized {
            Set(DataContext.shared.allCalendars.asIdentifiers)
        } else {
            Set()
        }
        self.months = self.generate(from: date)
    }

    private init(for date: Date) {
        self.date = date
        self.path = NavigationPath()
        self.calendars = if PermissionContext.shared.global == .authorized {
            Set(DataContext.shared.allCalendars.asIdentifiers)
        } else {
            Set()
        }
        self.months = self.generate(from: date)
    }

    func generateNext(_ count: Int) {
        if (self.months?.count ?? 0) == 0 {
            self.months = [.init()]
            self.generateNext(count - 1)
        } else {
            for _ in 0..<count {
                self.months!.append(self.months!.last!.next())
            }
            //            self.months?.removeFirst(count)
        }
    }

    func generatePrevious(_ count: Int) {
        if (self.months?.count ?? 0) == 0 {
            self.months = [.init()]
            self.generatePrevious(count - 1)
        } else {
            for _ in 0..<count {
                self.months!.prepend(self.months!.first!.prev())
            }
            //            self.months?.removeLast(count)
        }
    }

    var first: Month {
        if (self.months?.count ?? 0) == 0 {
            self.months = [.init()]
        }
        return self.months!.first!
    }

    func removeFirst(_ count: Int) {
        self.months!.removeFirst(count)
    }

    func removeFirstUpTo(_ month: Month) {
        self.removeFirst(self.months!.count - (self.months!.firstIndex(of: month)! + 1))
    }

    func removeLastUpTo(_ month: Month) {
        self.removeLast(self.months!.count - (self.months!.lastIndex(of: month)! + 1))
    }

    func removeLast(_ count: Int) {
        self.months!.removeLast(count)
    }

    var last: Month {
        if (self.months?.count ?? 0) == 0 {
            self.months = [.init()]
        }
        return self.months!.last!
    }

    func first(id: Int) -> Month? {
        self.months?.first { $0.id == id }
    }

    func last(id: Int) -> Month? {
        self.months?.last { $0.id == id }
    }

    func first(where filter: @escaping (Month) throws -> Bool) rethrows -> Month? {
        try self.months?.first(where: filter)
    }

    func firstIndex(where filter: @escaping (Month) -> Bool) -> Int? {
        self.months?.firstIndex(where: filter)
    }

    func last(where filter: @escaping (Month) throws -> Bool) rethrows -> Month? {
        try self.months?.last(where: filter)
    }

    func lastIndex(where filter: @escaping (Month) -> Bool) -> Int? {
        self.months?.lastIndex(where: filter)
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
        hasher.combine(self.date)
    }

    static func == (lhs: Month, rhs: Month) -> Bool {
        lhs.date == rhs.date
    }

    let id: ID
    let date: Date

    public func next() -> Month {
        Month(self.date.startOfNextMonth, prev: self.id)
    }

    public func prev() -> Month {
        Month(self.date.startOfPreviousMonth, next: self.id)
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
