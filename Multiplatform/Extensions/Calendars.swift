//
//  Calendars.swift
//  Cami
//
//  Created by Guillaume Coquard on 16/11/23.
//

import Foundation
import EventKit

extension Calendars: Observable {
    var asIdentifiers: [String] {
        self.map { calendar in
            calendar.calendarIdentifier
        }
    }
}

extension Array<String> {

    func asEKCalendars(
        with store: EKEventStore = CamiHelper.eventStore
    ) -> Calendars {

        let optionalCalendarList = self.map { calendar in
            store.calendar(withIdentifier: calendar)
        }
        return optionalCalendarList.filter { calendar in
            calendar != nil
        } as! Calendars

    }
    
}
