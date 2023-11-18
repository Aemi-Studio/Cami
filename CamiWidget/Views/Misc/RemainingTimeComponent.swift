//
//  RemainingTimeComponent.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 07/11/23.
//

import SwiftUI

struct RemainingTimeComponent: View {

    @EnvironmentObject private var entry: CamiWidgetEntry

    private var now: Date {
        entry.date
    }

    private let startDate: Date
    private let endDate: Date

    init(from startDate: Date, to endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
    }

    var body: some View {

        HStack(spacing: 4) {

            if startDate < now {

                let remainingTime: String = endDate.timeUntil

                Label("Remaining Time: \(remainingTime)", systemImage: "timer")
                    .labelStyle(.iconOnly)

                Text(remainingTime)
                
            } else {
                Text("\(startDate.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)))):\(startDate.formatted(.dateTime.minute(.twoDigits)))")
            }
        }
        .monospacedDigit()
        .fontWeight(.medium)
        .opacity(0.5)
    }

}
