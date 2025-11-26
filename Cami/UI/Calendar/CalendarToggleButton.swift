//
//  CalendarToggleButton.swift
//  Cami
//
//  Created by Guillaume Coquard on 17/03/25.
//

import Combine
import EventKit
import SwiftUI

struct CalendarToggleButton: View {
    let calendar: EKCalendar

    @State private var isSelected = true
    @State private var cancellable: AnyCancellable?

    private let settings = AppSettings.shared

    var body: some View {
        Toggle(isOn: $isSelected) {
            Text(calendar.title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.foreground)
        }
        .toggleStyle(.nativeCheckbox(placement: .trailing))
        .tint(Color(calendar.cgColor))
        .task {
            await loadInitialState()
            observeChanges()
        }
        .onChange(of: isSelected) { _, newValue in
            Task {
                await settings.setCalendarSelected(calendar.calendarIdentifier, selected: newValue)
            }
        }
    }

    private func loadInitialState() async {
        let selectedIDs = await settings.selectedCalendarIDs
        // If no calendars selected yet, default to all selected
        if selectedIDs.isEmpty {
            isSelected = true
        } else {
            isSelected = selectedIDs.contains(calendar.calendarIdentifier)
        }
    }

    private func observeChanges() {
        cancellable = settings.settingsChanged
            .receive(on: DispatchQueue.main)
            .sink { change in
                if case .calendarSelection(let ids) = change {
                    isSelected = ids.contains(calendar.calendarIdentifier)
                }
            }
    }
}
