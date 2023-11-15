//
//  CamiWidgetBirthdays.swift
//  Cami
//
//  Created by Guillaume Coquard on 14/11/23.
//

import SwiftUI
import EventKit

struct CamiWidgetBirthdays: View {

    var date: Date
    var birthdays: [EKEvent]

    var todayBirthdayEvent: EKEvent? {
        let sortedEvents: [EKEvent] = birthdays.sortedEventByAscendingDate()
        print(sortedEvents)
        return sortedEvents.first(where: { event in event.isEndingToday })
    }

    var nextBirthdays: (Int, [String]) {
        let firstBirthday : EKEvent = birthdays[0]

        var peopleBirthdays: [String] = birthdays.filter { event in
            event.isSameDayAs(event: firstBirthday) && event != firstBirthday
        }.map { event in
            ContactHelper.getNameFromContactIdentifier(event.birthdayContactIdentifier!)
        }

        peopleBirthdays.insert(
            ContactHelper.getNameFromContactIdentifier(
                firstBirthday.birthdayContactIdentifier!
            ),
            at: 0
        )

        return (
            Int((firstBirthday.endDate.zero - Date.now.zero) / (24 * 3600)),
            peopleBirthdays
        )
    }

    var body: some View {
        HStack {
            if todayBirthdayEvent != nil {
                Text("\(ContactHelper.getNameFromContactIdentifier(todayBirthdayEvent!.birthdayContactIdentifier!))")
            } else {
                if nextBirthdays.1.count > 1 {
                    Text("\(nextBirthdays.1.count) - \(nextBirthdays.0)d")
                } else {
                    Text("\(nextBirthdays.1[0]) - \(nextBirthdays.0)d")
                }
            }
        }
        .dynamicTypeSize(.xSmall)
        .fontWeight(.medium)
        .padding(.vertical, 2)
        .padding(.horizontal, 4)
        .background(.clear)
        .background(.red.opacity(0.5))
        .foregroundStyle(.white.opacity(0.75))
        .clipShape(
            UnevenRoundedRectangle(cornerRadii: .init(
                topLeading: 2,
                bottomLeading: 2,
                bottomTrailing: 2,
                topTrailing: 12
            ))
        )
        .lineLimit(1)
        .fontDesign(.rounded)
    }
}
