//
//  CalendarView.swift
//  Cami
//
//  Created by Guillaume Coquard on 15/11/23.
//

import SwiftUI

struct CalendarView: View {
    
    private var birthdays: Events {
        return CamiHelper.birthdays()
    }

    private var subscribedCalendars: Calendars {
        return CamiHelper.allCalendars.filter({ cal in cal.isSubscribed })
    }

    var body: some View {

        EmptyView()

    }
}

#Preview {
    CalendarView()
}
