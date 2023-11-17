//
//  CalendarView.swift
//  Cami
//
//  Created by Guillaume Coquard on 15/11/23.
//

import SwiftUI
import EventKit
import Contacts

struct CalendarView: View {
    
    private var birthdays: EventList {
        return CamiHelper.birthdays()
    }

    private var subscribedCalendars: [EKCalendar] {
        return CamiHelper.allCalendars.filter({ cal in cal.isSubscribed })
    }

    var body: some View {

        EmptyView()

    }
}

#Preview {
    CalendarView()
}
