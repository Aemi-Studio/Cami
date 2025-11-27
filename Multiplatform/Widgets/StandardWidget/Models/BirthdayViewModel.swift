//
//  BirthdayViewModel.swift
//  Cami
//
//  Created by Claude on 28/09/25.
//

import Foundation

@MainActor
final class BirthdayViewModel {
    let birthdays: [WidgetCalendarItem]
    let referenceDate: Date
    let dataContext: DataContext

    private var _validBirthdays: [WidgetCalendarItem]?
    private var _todayBirthdayEvent: WidgetCalendarItem??
    private var _nextBirthdaysInfo: (daysUntil: Int, names: [String])?

    init(birthdays: [WidgetCalendarItem], referenceDate: Date, dataContext: DataContext) {
        self.birthdays = birthdays
        self.referenceDate = referenceDate
        self.dataContext = dataContext
    }

    var validBirthdays: [WidgetCalendarItem] {
        if let cached = _validBirthdays {
            return cached
        }
        let filtered = birthdays.filter { $0.contactIdentifier != nil }
        _validBirthdays = filtered
        return filtered
    }

    var todayBirthdayEvent: WidgetCalendarItem? {
        if let cached = _todayBirthdayEvent {
            return cached
        }
        let today = validBirthdays.first(where: \.isEndingToday)
        _todayBirthdayEvent = today
        return today
    }

    var nextBirthdaysInfo: (daysUntil: Int, names: [String]) {
        if let cached = _nextBirthdaysInfo {
            return cached
        }

        guard !validBirthdays.isEmpty, let firstBirthday = validBirthdays.first else {
            let result = (0, [String]())
            _nextBirthdaysInfo = result
            return result
        }

        let sameDayBirthdays = validBirthdays.filter { event in
            event.isSameDay(as: firstBirthday) && event != firstBirthday
        }

        var names: [String] = sameDayBirthdays.compactMap { event in
            event.contactIdentifier.map { dataContext.resolveContactName($0) }
        }

        if let contactId = firstBirthday.contactIdentifier {
            names.insert(dataContext.resolveContactName(contactId), at: 0)
        }

        let daysUntil = Int(firstBirthday.boundEnd.zero - referenceDate.zero)
        let result = (daysUntil, names)
        _nextBirthdaysInfo = result
        return result
    }

    func birthdayInfo(for event: WidgetCalendarItem) -> (name: String, age: Int)? {
        guard let contactId = event.contactIdentifier,
              let birthdate = dataContext.resolveBirthdate(contactId)
        else {
            return nil
        }

        let name = dataContext.resolveContactName(contactId)
        let age = birthdate.yearsAgo
        return (name, age)
    }
}
