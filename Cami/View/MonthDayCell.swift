//
//  MonthDayCell.swift
//  Cami
//
//  Created by Guillaume Coquard on 19/11/23.
//

import SwiftUI

struct MonthDayCell: View {

    @Environment(ViewModel.self)
    private var model: ViewModel

    let day: Day

    var body: some View {
        NavigationLink(value: day) {
            VStack(alignment: .center, spacing: 6) {
                HStack {
                    
                    Text(day.date.formatted(.dateTime.day(.defaultDigits)))
                        .font(.title3)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                        .lineLimit(1)
                        .lineSpacing(0)
                        .padding(0)
                }

                HStack(alignment:.center, spacing: 3) {
                    let calendars: Calendars = Array(model.calendars.intersection(day.calendars)).asEKCalendars()
                    if calendars.count > 0 {
                        ForEach(Array(model.calendars.intersection(day.calendars)).asEKCalendars(), id: \.self) { cal in
                            Circle()
                                .frame(width: 6, height: 6)
                                .foregroundStyle(Color(cgColor: cal.cgColor))
                        }
                    } else {
                        Circle()
                            .frame(height: 6)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(Color.clear)
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())

    }
}
