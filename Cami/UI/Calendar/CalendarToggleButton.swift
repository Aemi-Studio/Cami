//
//  CalendarToggleButton.swift
//  Cami
//
//  Created by Guillaume Coquard on 17/03/25.
//

import EventKit
import SwiftUI

struct CalendarToggleButton: View {
    @Environment(\.views) private var views: UIContext!
    let calendar: EKCalendar

    private func isSelected(_ calendar: String) -> Bool {
        views.calendars.contains(calendar)
    }

    var body: some View {
        Button {
            if !isSelected(calendar.calendarIdentifier) {
                views.calendars.insert(calendar.calendarIdentifier)
            } else {
                views.calendars.remove(calendar.calendarIdentifier)
            }
        } label: {
            HStack(alignment: .center, spacing: 8) {
                VStack(alignment: .leading) {
                    let imageName = isSelected(calendar.calendarIdentifier)
                        ? "checkmark.circle.fill"
                        : "circle"
                    Label("\(calendar.source.title) - \(calendar.title)", systemImage: imageName)
                        .labelStyle(.iconOnly)
                        .foregroundStyle(Color(cgColor: calendar.cgColor))
                }
                .fontWeight(.bold)
                .font(.title)

                VStack(alignment: .leading, spacing: 4) {
                    Text(calendar.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.foreground)
                }
            }
            .padding()
        }
        .buttonStyle(.bordered)
    }
}
