//
//  MonthModel.swift
//  Cami
//
//  Created by Guillaume Coquard on 20/11/23.
//

import Foundation
import SwiftUI

@Observable final class ViewModel: ObservableObject {

    class Month: Identifiable {

        enum Side: Int {
            case prev = -1
            case next = 1
        }

        let date: Date
        let id: Int

        private var _prev: Month? = nil
        private var _next: Month? = nil

        public func next() -> Month {
            if self._next == nil {
                self._next = Month(self.date.startOfNextMonth, prev: self)
            }
            return self._next!
        }

        public func prev() -> Month {
            if self._prev == nil {
                self._prev = Month(self.date.startOfPreviousMonth, next: self)
            }
            return self._prev!
        }

        public func first() -> Month {
            return if self._prev != nil {
                self._prev!.last()
            } else {
                self
            }
        }

        public func last() -> Month {
            return if self._next != nil {
                self._next!.last()
            } else {
                self
            }
        }

        public func unregister(_ side: Side) {
            switch side {
                case .prev:
                    self._prev = nil
                case .next:
                    self._next = nil
            }
        }

        public func destroy() {
            if self._prev != nil {
                self._prev!.unregister(.next)
            } else
            if self._next != nil {
                self._next!.unregister(.prev)
            }
        }

        init(_ date: Date = Date.now.startOfMonth.zero, prev: Month? = nil, next: Month? = nil, id: Int = 0) {
            self.date = date
            if prev != nil {
                self._prev = prev
                self.id = prev!.id + 1
            } else if next != nil {
                self._next = next
                self.id = next!.id - 1
            } else {
                self.id = id
            }
        }

    }

    private func gen(from startDate: Date, with startId: Int = -3, count: Int = 7) -> [Month] {
        var months: [Month] = []
        let newDate: Date = (startDate.startOfMonth.zero + DateComponents(month: startId)).startOfMonth.zero
        for _ in 0..<count {
            let prev: Month? = months.last
            if prev != nil {
                months.append(prev!.next())
            } else {
                months.append(Month(newDate, id: startId))
            }
        }
        return months
    }

    public func reset() {
        self.calendars = Set(CamiHelper.allCalendars.asIdentifiers)
        self.months = self.gen(from: self.date)
    }

    public var authStatus: AuthorizationSet
    public var date: Date
    public var months: [Month]? = nil
    public var path: NavigationPath
    public var calendars: Set<String>
    public var weekdaysCount: Int {
        Calendar.autoupdatingCurrent.maximumRange(of: .weekday)!.count
    }

    init(for date: Date, path: NavigationPath) {
        let authStatus = CamiHelper.authorizationStatus()
        self.authStatus = authStatus
        self.date = date
        self.path = path
        self.calendars = if authStatus.calendars.status == .authorized {
            .init(CamiHelper.allCalendars.asIdentifiers)
        } else {
            .init()
        }
        self.months = self.gen(from: date)
    }

    init(for date: Date) {
        let authStatus = CamiHelper.authorizationStatus()
        self.authStatus = authStatus
        self.date = date
        self.path = NavigationPath()
        self.calendars = if authStatus.calendars.status == .authorized {
            .init(CamiHelper.allCalendars.asIdentifiers)
        } else {
            .init()
        }
        self.months = self.gen(from: date)
    }


    func next() -> Month {
        if self.months != nil {
            if self.months!.count > 0 {
                self.months!.append(self.months!.last!.next())
//                self.months!.removeFirst().destroy()
            } else {
                self.months!.append(.init())
            }
        } else {
            self.months = [.init()]
        }
        return self.months!.last!
    }

    func prev() -> Month {
        if self.months != nil {
            if self.months!.count > 0 {
                self.months!.insert(self.months!.first!.prev(), at: 0)
//                self.months!.removeLast().destroy()
            } else {
                self.months!.append(.init())
            }
        } else {
            self.months = [.init()]
        }
        return self.months!.first!
    }

    var first: Month {
        get {
            if self.months == nil {
                self.months = [.init()]
            }
            return self.months!.first!
        }
    }

    var last: Month {
        get {
            if self.months == nil {
                self.months = [.init()]
            }
            return self.months!.last!
        }
    }

    func get(id: Int) -> Month? {
        self.months?.first { $0.id == id }
    }

}
