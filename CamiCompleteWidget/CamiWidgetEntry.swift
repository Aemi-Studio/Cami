//
//  CamiWidgetEntry.swift
//  Cami
//
//  Created by Guillaume Coquard on 05/11/23.
//

import SwiftUI
import EventKit
import WidgetKit

struct CamiWidgetEntry: TimelineEntry {
    var date: Date = Date.now
    var calendars: [String] = []
    var allDayEventStyle: AllDayEventStyle = .event
    var events: EventDict = [:]
    var birthdays: EventList = []
}
