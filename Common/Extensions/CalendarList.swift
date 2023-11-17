//
//  CalendarList.swift
//  Cami
//
//  Created by Guillaume Coquard on 16/11/23.
//

import Foundation
import EventKit

extension CalendarList {
    var asIdentifiers: [String] {
        self.map { calendar in
            calendar.calendarIdentifier
        }
    }
}

extension Array<String> {

    func asEKCalendars(
        with store: EKEventStore = CamiHelper.eventStore
    ) -> CalendarList {

        let optionalCalendarList = self.map { calendar in
            store.calendar(withIdentifier: calendar)
        }
        return optionalCalendarList.filter { calendar in
            calendar != nil
        } as! CalendarList

    }
    
}
