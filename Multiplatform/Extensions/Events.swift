//
//  Events.swift
//  Cami
//
//  Created by Guillaume Coquard on 17/11/23.
//

import Foundation
import EventKit
import SwiftUI

extension Events {

    /// An array of events sorted by start date in ascending order.
    func sorted(_ order: ComparisonResult = .orderedAscending) -> Events {
        self.sorted(by: { (first: EKEvent, second: EKEvent) in
            first.compareStartDate(with: second) == .orderedAscending
        })
    }

    private func similarEvents(_ event: EKEvent) -> [(EKEvent,Int)] {
        var outputList: [(EKEvent,Int)] = []
        for (index,_event) in self.enumerated() {
            if (
                event.eventIdentifier != _event.eventIdentifier &&
                event.title == _event.title &&
                event.calendar.calendarIdentifier == _event.calendar.calendarIdentifier
            ) {
                outputList.append((_event,index))
            }
        }
        return outputList
    }

    func reduced() -> [(EKEvent, Events)] {
        var result: [(EKEvent, Events)] = []
        var ignoredEvents: Set<Int> = Set<Int>()
        for (index,event) in self.enumerated() {
            if !ignoredEvents.contains( index ) {
                ///Get events with similar name of the same calendar
                let similarEvents: [(EKEvent,Int)] = self.similarEvents(event)
                ///Save indiced in the ignored list
                for value in similarEvents {
                    ignoredEvents.insert( value.1 )
                }
                ///Extract the dates from the event list
                var __events = [event]
                __events.append(
                    contentsOf: similarEvents.map { (__event,_) in __event }
                )
                result.append((event,__events))
            }
        }
        return result
    }

    func mapped(relativeTo date: Date) -> EventDict {
        var eventsDictionary: EventDict = [:]
        for event in self {
            if event.spansMore(than: date) {
                eventsDictionary.append(to: (date + DateComponents(day: -1)).zero, event)
            } else {
                eventsDictionary.append(to: event.startDate.zero, event)
            }
        }
        return eventsDictionary
    }

}
