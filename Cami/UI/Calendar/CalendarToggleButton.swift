//
//  CalendarToggleButton.swift
//  Cami
//
//  Created by Guillaume Coquard on 17/03/25.
//

import EventKit
import SwiftUI

struct CalendarToggleButton: View {
    @Environment(\.appState) private var state
    
    var context: SingleDayContext? {
        state?.dayContext
    }
    
    let calendar: EKCalendar
    
    var body: some View {
        Toggle(isOn: .constant(true)) {
            Text(calendar.title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.foreground)
        }
        .toggleStyle(.nativeCheckbox(placement: .trailing))
        .tint(Color(calendar.cgColor))
    }
}
