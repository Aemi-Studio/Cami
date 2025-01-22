//
//  MonthView.swift
//  Cami
//
//  Created by Guillaume Coquard on 19/11/23.
//

import SwiftUI

struct MonthView: View {
    let date: Date

    private var weeks: Weeks {
        date.getDates(from: .month).weeks
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(date.formatted(.dateTime.month(.abbreviated)))
                .font(.subheadline)
                .fontWeight(.bold)
                .textCase(.uppercase)
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(weeks, id: \.self) { week in
                    MonthWeekRow(week: week)
                }
            }
        }
    }
}
