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
    var events: EKEventMap = [:]
    var birthdays: EKEventList = []
}
