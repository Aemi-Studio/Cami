//
//  MonthWeekRow.swift
//  Cami
//
//  Created by Guillaume Coquard on 19/11/23.
//

import SwiftUI

struct MonthWeekRow: View {

    @Environment(ViewModel.self)
    private var model: ViewModel

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
                        ForEach(0..<model.weekdaysCount - week.count, id: \.self) { _ in
                            Color.clear
                        }
                    }
                    ForEach(week, id: \.self) { day in
                        MonthDayCell(day: day)
                            .foregroundStyle(.foreground)
                            .frame(maxWidth: .infinity)
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundStyle( day.date.isToday ? .gray.opacity(0.32) : .clear )
                            }
                    }
                    if lastWeekOfTheMonth {
                        ForEach(0..<model.weekdaysCount - week.count, id: \.self) { _ in
                            Color.clear
                        }
                    }
                }
            }
    }
}
