//
//  Events.swift
//  Cami
//
//  Created by Guillaume Coquard on 17/11/23.
//

import EventKit
import Foundation
import SwiftUI

extension Events {
    /// An array of events sorted by start date in ascending order.
    func sorted(_: ComparisonResult = .orderedAscending) -> Events {
        sorted(by: { (first: EKEvent, second: EKEvent) in
            first.compareStartDate(with: second) == .orderedAscending
        })
    }

    private func similarEvents(_ event: EKEvent) -> [(EKEvent, Int)] {
        var outputList: [(EKEvent, Int)] = []
        for (index, potentialSimilarEvent) in enumerated() {
            if event.eventIdentifier != potentialSimilarEvent.eventIdentifier,
               event.title == potentialSimilarEvent.title,
               event.calendar.calendarIdentifier == potentialSimilarEvent.calendar.calendarIdentifier {
                outputList.append((potentialSimilarEvent, index))
            }
        }
        return outputList
    }

    func reduced() -> [(EKEvent, Events)] {
        var result: [(EKEvent, Events)] = []
        var ignoredEvents = Set<Int>()
        for (index, event) in enumerated() where !ignoredEvents.contains(index) {
            /// Get events with similar name of the same calendar
            let similarEvents: [(EKEvent, Int)] = self.similarEvents(event)
            /// Save indiced in the ignored list
            for value in similarEvents {
                ignoredEvents.insert(value.1)
            }
            /// Extract the dates from the event list
            var events = [event]
            events.append(
                contentsOf: similarEvents.map { event, _ in event }
            )
            result.append((event, events))
        }
        return result
    }
}

extension CItems {
    func mapped(relativeTo date: Date) -> CIDict {
        var itemsDictionary: CIDict = [:]
        for item in self {
            if item.spansMore(than: date) {
                itemsDictionary.append(to: (date + DateComponents(day: -1)).zero, item)
            } else {
                itemsDictionary.append(to: item.beginDate.zero, item)
            }
        }
        return itemsDictionary
    }
}
