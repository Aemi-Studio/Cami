//
//  EventHelper+Extensions.swift
//  Cami
//
//  Created by Guillaume Coquard on 11/09/24.
//

import Foundation
import EventKit
import SwiftUI

extension EventHelper {
    static func openCalendarEvent(withId eventId: String) {
        if self.calendarsAccess {
            DispatchQueue.main.async {
                if let event = EventHelper.event(for: eventId) {
                    ViewModel.shared.path.append(event)
                }
            }
        }
    }

    static func openCalendarDay(atTime timeInterval: String) {
        if self.calendarsAccess {
            DispatchQueue.main.async {
                ViewModel.shared.path.append(Day(.init(timeIntervalSinceReferenceDate: TimeInterval(timeInterval)!)))
            }
        }
    }
}
