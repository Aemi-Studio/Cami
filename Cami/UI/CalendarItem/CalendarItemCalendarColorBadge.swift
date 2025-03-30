//
//  CalendarItemCalendarColorBadge.swift
//  Cami
//
//  Created by Guillaume Coquard on 21/03/25.
//

import SwiftUI
import EventKit

struct CalendarItemCalendarColorBadge: View {
    @ScaledMetric private var size: CGFloat = 10

    let item: EKCalendarItem

    private var color: Color {
        Color(item.calendar.cgColor)
    }

    var body: some View {
        Circle()
            .fill(color.opacity(0.8))
            .stroke(color, lineWidth: 0.5)
            .frame(width: size, height: size)
    }
}
