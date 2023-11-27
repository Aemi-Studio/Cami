//
//  MonthDayCell.swift
//  Cami
//
//  Created by Guillaume Coquard on 19/11/23.
//

import SwiftUI
import EventKit

struct MonthDayCell: View {

    @Environment(ViewModel.self)
    private var model: ViewModel

    @State
    private var colors: [Generic<Color>]?

    let day: Day

    var body: some View {
        Button {
            model.path.append(day)
        } label: {
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

                HStack(alignment: .center, spacing: 3) {
                    if colors != nil && colors!.count > 0 {
                        ForEach(colors!) { color in
                            Circle()
                                .frame(width: 6, height: 6)
                                .foregroundStyle( color.value )
                        }
                    } else {
                        Color.clear.frame(height: 6)
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
        .task(priority: .low) {
            let calendars: Set<String> = await day.lazyInitCalendars()
            colors = Array(model.calendars.intersection( calendars ))
                .asEKCalendars()
                .map { Generic<Color>(Color(cgColor: $0.cgColor)) }
        }
    }
}
