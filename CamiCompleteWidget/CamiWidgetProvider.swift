//
//  CamiWidgetProvider.swift
//  Cami
//
//  Created by Guillaume Coquard on 05/11/23.
//

import SwiftUI
import EventKit
import WidgetKit

struct CamiWidgetProvider: AppIntentTimelineProvider {
    
    typealias Entry = CamiWidgetEntry
    typealias Intent = CamiCompleteWidgetIntent

    func placeholder(in context: Context) -> Entry {
        let eventDict = CamiHelper.events(calendars: [])
        let birthdays = CamiHelper.birthdays()
        return CamiWidgetEntry(
            events: eventDict,
            birthdays: birthdays
        )
    }
    
    func snapshot(for configuration: Intent, in context: Context) async -> Entry {

        let calendars: [String] = configuration.calendars.map { calendar in
            calendar.calendar
        }

        let allDayEventStyle: AllDayEventStyle = configuration.allDayEventStyle

        let eventDict = CamiHelper.events(calendars: calendars)
        let birthdays = CamiHelper.birthdays()

        return CamiWidgetEntry(
            calendars: calendars,
            allDayEventStyle: allDayEventStyle,
            events: eventDict,
            birthdays: birthdays
        )
    }

    func timeline(for configuration: Intent, in context: Context) async -> Timeline<Entry> {
        
        let calendars: [String] = configuration.calendars.map { calendar in
            calendar.calendar
        }

        let allDayEventStyle: AllDayEventStyle = configuration.allDayEventStyle

        let eventDict = CamiHelper.events(calendars: calendars)
        let birthdays = CamiHelper.birthdays()

        return Timeline(
            entries: [
                CamiWidgetEntry(
                    calendars: calendars,
                    allDayEventStyle: allDayEventStyle,
                    events: eventDict,
                    birthdays: birthdays
                )
            ],
            policy: .atEnd
        )
    }

}
