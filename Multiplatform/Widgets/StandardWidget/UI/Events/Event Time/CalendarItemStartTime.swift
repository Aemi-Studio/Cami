//
//  CalendarItemStartTime.swift
//  Cami
//
//  Created by Guillaume Coquard on 12/03/25.
//

import SwiftUI

struct CalendarItemStartTime: View {
    private let item: CalendarItem

    init(for item: CalendarItem) {
        self.item = item
    }

    var body: some View {
        Text(item.boundStart.formattedHour)
            .accessibilityLabel(String(localized: "This event starts at \(item.boundStart.formattedHour)."))
            .opacity(0.5)
    }
}
