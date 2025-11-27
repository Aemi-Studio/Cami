//
//  CalendarItemType.swift
//  Cami
//
//  Created by Guillaume Coquard on 26.11.25.
//

import EventKit
import SwiftUI

enum CalendarItemType: CaseIterable {
    case event
    case reminder
}

/// View model for day visibility toggles.
///
/// DayViewModel syncs visibility state with AppSettings for persistence.
@Observable
@MainActor
final class DayViewModel: Loggable {
    typealias UpdateAction = (CalendarItemType) -> Void

    private let settings = AppSettings.shared
    private var observationTask: Task<Void, Never>?

    var showEvents: Bool = true
    var showReminders: Bool = true

    var visibleTypes: Set<CalendarItemType> {
        var types = Set<CalendarItemType>()
        if showEvents { types.insert(.event) }
        if showReminders { types.insert(.reminder) }
        return types
    }

    init() {
        Task { [weak self] in
            await self?.loadFromSettings()
        }
        startObserving()
    }

    private func loadFromSettings() async {
        showEvents = await settings.showEvents
        showReminders = await settings.showReminders
    }

    private func startObserving() {
        observationTask = Task { [weak self] in
            guard let self else { return }
            for await change in await settings.settingsChanges() {
                switch change {
                case .showEvents(let show):
                    showEvents = show
                case .showReminders(let show):
                    showReminders = show
                default:
                    break
                }
            }
        }
    }

    func filter(_ item: EKCalendarItem) -> Bool {
        switch item {
        case is EKEvent: showEvents
        case is EKReminder: showReminders
        default: false
        }
    }

    func bound(to type: CalendarItemType) -> Binding<Bool> {
        switch type {
        case .event:
            Binding {
                self.showEvents
            } set: { isOn in
                self.showEvents = isOn
                Task {
                    await self.settings.setShowEvents(isOn)
                }
            }
        case .reminder:
            Binding {
                self.showReminders
            } set: { isOn in
                self.showReminders = isOn
                Task {
                    await self.settings.setShowReminders(isOn)
                }
            }
        }
    }
}
