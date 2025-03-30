//
//  Deeplink.swift
//  Cami
//
//  Created by Guillaume Coquard on 23/01/25.
//

import EventKit
import Foundation

extension DataContext {
    func destination(for item: CalendarItem, inPlace: Bool = false) -> URL {
        let url = switch item.kind {
            case .event: goesToEvent(for: item)
            case .reminder: goesToReminder(for: item)
        }
        return url ?? URL(filePath: "")
    }

    private func goesToEvent(for item: CalendarItem?, inPlace: Bool = false) -> URL? {
        guard let item else { return nil }
        return if inPlace {
            URL(string: "camical:event?id=\(item.id)")!
        } else {
            URL(string: "calshow:\(item.boundStart.timeIntervalSinceReferenceDate)")!
        }
    }

    private func goesToReminder(for item: CalendarItem?, inPlace: Bool = false) -> URL? {
        guard let item else { return nil }
        return if inPlace {
            URL(string: "reminder:event?id=\(item.id)")!
        } else {
            URL(string: "reminder:\(item.boundStart.timeIntervalSinceReferenceDate)")!
        }
    }

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
