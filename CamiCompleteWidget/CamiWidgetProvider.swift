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

        let eventDict = CamiHelper.events(
            calendars: configuration.calendars.map { $0.calendar }
        )
        let birthdays = CamiHelper.birthdays()

        return CamiWidgetEntry(
            config: CamiWidgetConfiguration(
                allDayEventStyle: configuration.allDayEventStyle,
                displayBirthdays: configuration.displayBirthdays,
                groupEvents: configuration.groupEvents
            ),
            events: eventDict,
            birthdays: birthdays
        )
    }

    func timeline(for configuration: Intent, in context: Context) async -> Timeline<Entry> {
        
        let eventDict = CamiHelper.events(
            calendars: configuration.calendars.map { $0.calendar }
        )
        let birthdays = CamiHelper.birthdays()

        return Timeline(
            entries: [
                CamiWidgetEntry(
                    config: CamiWidgetConfiguration(
                        allDayEventStyle: configuration.allDayEventStyle,
                        displayBirthdays: configuration.displayBirthdays,
                        groupEvents: configuration.groupEvents
                    ),
                    events: eventDict,
                    birthdays: birthdays
                )
            ],
            policy: .after(Calendar.current.date(byAdding: .minute, value: 1, to: Date.now)!)
        )
    }

}
