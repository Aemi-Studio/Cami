//
//  DayView.swift
//  Cami
//
//  Created by Guillaume Coquard on 20/11/23.
//

import SwiftUI

struct DayView: View {

    @Environment(ViewModel.self)
    private var model: ViewModel

    var day: Day

    init(_ day: Day) {
        self.day = day
    }

    var body: some View {
        ScrollView {
            VStack {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(day.events.filter {
                        model.calendars.contains($0.calendar.calendarIdentifier)
                    }, id:\.self) { event in
                        HStack(alignment: .center, spacing: 0) {
                            Text(event.title)
                            Spacer()
                            VStack(alignment: .center, spacing: 2) {
                                Text(event.startDate.formatted(.dateTime.hour(.twoDigits(amPM: .omitted))))
                                Text(event.endDate.formatted(.dateTime.hour(.twoDigits(amPM: .omitted))))
                            }
                        }
                        .roundedBorder(event.calendar.cgColor)
                    }
                }
            }
        }
        .navigationTitle(day.date.formatted(.dateTime.day(.defaultDigits).day().month(.abbreviated).year()))
    }
}
