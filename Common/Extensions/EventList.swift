//
//  EventList.swift
//  Cami
//
//  Created by Guillaume Coquard on 17/11/23.
//

import Foundation
import EventKit
import OSLog

extension EventList {

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

    func reduced() -> [(EKEvent, EventList)] {

        var result: [(EKEvent, EventList)] = []
        var ignoredEvents: [Int] = []

        for (index,event) in self.enumerated() {

            if !ignoredEvents.contains( index ) {

                ///Get events with similar name of the same calendar
                let similarEvents: [(EKEvent,Int)] = self.similarEvents(event)

                ///Save indiced in the ignored list
                for value in similarEvents {
                    ignoredEvents.append( value.1 )
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

}
