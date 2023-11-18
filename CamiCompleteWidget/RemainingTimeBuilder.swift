//
//  RemainingTimeBuilder.swift
//  Cami
//
//  Created by Guillaume Coquard on 07/11/23.
//

import SwiftUI


struct RemainingTimeComponent: View {

    var startDate: Date
    var endDate: Date

    var body: some View {
        let now = Date.now
        HStack(spacing: 4) {
            if startDate < now {
                let remainingTime: String = CamiUtils.remainingTime(endDate)
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
