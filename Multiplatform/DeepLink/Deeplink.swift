//
//  Deeplink.swift
//  Cami
//
//  Created by Guillaume Coquard on 23/01/25.
//

import EventKit
import Foundation

// MARK: - Widget Calendar Item Support

extension DataContext {
    /// Creates a destination URL for a widget calendar item
    func destination(for item: WidgetCalendarItem, inPlace: Bool = false) -> URL {
        let url: URL? =
            switch item.kind {
            case .event, .birthday:
                eventURL(id: item.id, date: item.boundStart, inPlace: inPlace)
            case .reminder:
                reminderURL(id: item.id, date: item.boundStart, inPlace: inPlace)
            }
        return url ?? URL(filePath: "")
    }
}

// MARK: - EventKit Type Support

extension DataContext {
    /// Creates a destination URL for an EKEvent
    func destination(for event: EKEvent, inPlace: Bool = false) -> URL {
        eventURL(
            id: event.calendarItemIdentifier,
            date: event.startDate,
            inPlace: inPlace
        ) ?? URL(filePath: "")
    }

    /// Creates a destination URL for an EKReminder
    func destination(for reminder: EKReminder, inPlace: Bool = false) -> URL {
        let date = reminder.dueDateComponents?.date ?? .now
        return reminderURL(
            id: reminder.calendarItemIdentifier,
            date: date,
            inPlace: inPlace
        ) ?? URL(filePath: "")
    }

    /// Creates a destination URL for any EKCalendarItem
    func destination(for item: EKCalendarItem, inPlace: Bool = false) -> URL {
        if let event = item as? EKEvent {
            destination(for: event, inPlace: inPlace)
        } else if let reminder = item as? EKReminder {
            destination(for: reminder, inPlace: inPlace)
        } else {
            URL(filePath: "")
        }
    }
}

// MARK: - Date and Creation URLs

extension DataContext {
    func destination(for date: Date, inPlace: Bool = false) -> URL {
        if inPlace {
            URL(string: "camical:day?time=\(date.timeIntervalSinceReferenceDate)")!
        } else {
            URL(string: "calshow:\(date.timeIntervalSinceReferenceDate)")!
        }
    }

    var creationURL: URL {
        URL(string: "camical:create")!
    }
}

// MARK: - Private URL Builders

private extension DataContext {
    func eventURL(id: String, date: Date, inPlace: Bool) -> URL? {
        if inPlace {
            URL(string: "camical:event?id=\(id)")
        } else {
            URL(string: "calshow:\(date.timeIntervalSinceReferenceDate)")
        }
    }

    func reminderURL(id: String, date: Date, inPlace: Bool) -> URL? {
        if inPlace {
            URL(string: "camical:reminder?id=\(id)")
        } else {
            URL(string: "x-apple-reminderkit://remitem/\(id)")
        }
    }
}
