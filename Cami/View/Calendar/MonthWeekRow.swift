//
//  MonthWeekRow.swift
//  Cami
//
//  Created by Guillaume Coquard on 19/11/23.
//

import SwiftUI

struct MonthWeekRow: View {

    @Environment(\.views) private var views

    private var weekdaysCount: Int {
        views?.weekdaysCount ?? 7
    }

    let week: Days
    let firstWeekOfTheMonth: Bool
    let lastWeekOfTheMonth: Bool

    init(
        week: Dates
    ) {
        self.week = week.asDays()
        self.firstWeekOfTheMonth = week.first! == week.first!.startOfMonth
        self.lastWeekOfTheMonth = week.last! == week.last!.endOfMonth
    }

    var body: some View {
        Grid {
            GridRow {
                if firstWeekOfTheMonth {
                    ForEach(0..<weekdaysCount - week.count, id: \.self) { _ in
                        Color.clear
                    }
                }
                ForEach(week, id: \.self) { day in
                    MonthDayCell(day: day)
                        .foregroundStyle(.foreground)
                        .frame(maxWidth: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundStyle( day.date.isToday
                                                    ? .gray.opacity(0.32)
                                                    : .clear
                                )
                        }
                }
                if lastWeekOfTheMonth {
                    ForEach(0..<weekdaysCount - week.count, id: \.self) { _ in
                        Color.clear
                    }
                }
            }
        }
    }
}
