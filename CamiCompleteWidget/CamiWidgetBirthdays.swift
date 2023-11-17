//
//  CamiWidgetBirthdays.swift
//  Cami
//
//  Created by Guillaume Coquard on 14/11/23.
//

import SwiftUI
import EventKit
import WidgetKit

struct CamiWidgetBirthdays: View {

    @Environment(\.widgetFamily) var widgetFamily: WidgetFamily

    var date: Date
    var birthdays: EventList

    private var isSmall: Bool {
        widgetFamily == WidgetFamily.systemSmall
    }

    private let bCalColor: Color = Color(
        cgColor: CamiHelper.birthdayCalendar?.cgColor
        ?? .init(red: 1, green: 0, blue: 0, alpha: 1)
    )

    private var todayBirthdayEvent: EKEvent? {
        return birthdays.first(where: { event in event.isEndingToday })
    }

    private var nextBirthdays: (Days, [String]) {

        if birthdays.count > 0 {
            let firstBirthday: EKEvent = birthdays[0]

            var peopleBirthdays: [String] = birthdays.filter { event in
                event.isSameDayAs(event: firstBirthday) && event != firstBirthday
            }.map { event in
                ContactHelper.resolveContactName( 
                    event.birthdayContactIdentifier!
                )
            }

            peopleBirthdays.insert(
                ContactHelper.resolveContactName(
                    firstBirthday.birthdayContactIdentifier!
                ),
                at: 0
            )

            return (
                Int((firstBirthday.endDate.zero - Date.now.zero) / (24 * 3600)) as Days,
                peopleBirthdays
            )
        }
        else {
            return (0 as Days,[])
        }
    }

    var body: some View {
        if nextBirthdays.1.count > 0 {

            HStack(alignment: .center, spacing: 4) {

                if todayBirthdayEvent != nil {

                    let name = ContactHelper.resolveContactName(
                        todayBirthdayEvent!.birthdayContactIdentifier!
                    )
                    let age = ContactHelper.resolveBirthdate( todayBirthdayEvent!.birthdayContactIdentifier!
                    )!.yearsAgo

                    HStack(spacing: 0) {

                        Text("\(age)")
                            .hiddenIf(isSmall)

                        Label("\(age) years old", systemImage: "birthday.cake.fill")
                            .labelStyle(.iconOnly)
                            .font(.caption2)
                            .scaleEffect(0.8)
                            .lineSpacing(0)
                    }
                        .miniBadge(color: bCalColor)

                    Text("\(name)")
                        .hiddenIf(isSmall)

                } else {
                    if nextBirthdays.1.count > 1 {

                        Text(nextBirthdays.0.toDays)
                            .miniBadge(color: bCalColor)

                        Text("\(nextBirthdays.1.count)")
                            .hiddenIf(isSmall)


                    } else {

                        Text(nextBirthdays.0.toDays)
                            .miniBadge(color: bCalColor)

                        Text("\(nextBirthdays.1[0])")
                            .hiddenIf(isSmall)
                    }
                }
            }
            .font(.caption)
            .fontWeight(.bold)
            .fontWidth(.compressed)
            .pad([
                .notSmall: .init(top: 4, leading: 4, bottom: 4, trailing: 6),
                .systemSmall: .init(all: 0)
            ])
            .background(isSmall ? .clear : bCalColor.opacity(0.1))
            .foregroundStyle(bCalColor)
            .rounded([
                .all: .init(
                    topLeading: 4,
                    bottomLeading: 4,
                    bottomTrailing: 4,
                    topTrailing: 12
                )
            ])
            .lineLimit(1)
            .fontDesign(.rounded)
        } else {
            EmptyView()
        }
    }
}
