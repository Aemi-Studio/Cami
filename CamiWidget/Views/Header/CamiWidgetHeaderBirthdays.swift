//
//  CamiWidgetHeaderBirthdays.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 14/11/23.
//

import SwiftUI
import EventKit
import WidgetKit

struct CamiWidgetHeaderBirthdays: View {

    @Environment(\.widgetFamily)
    private var widgetFamily: WidgetFamily

    @EnvironmentObject
    private var entry: CamiWidgetEntry

    private var birthdays: Events {
        entry.birthdays
    }

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

    private var nextBirthdays: (Seconds, [String]) {

        if birthdays.count > 0 {
            let firstBirthday: EKEvent = birthdays[0]

            var peopleBirthdays: [String] = birthdays.filter { event in
                event.isSameDay(as: firstBirthday) && event != firstBirthday
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
                Int(firstBirthday.endDate.zero - entry.date.zero) as Seconds,
                peopleBirthdays
            )
        } else {
            return (0 as Seconds, [])
        }
    }

    var body: some View {
        if nextBirthdays.1.count > 0 {
            HStack(alignment: .center, spacing: 4) {
                if todayBirthdayEvent != nil {

                    let name = ContactHelper.resolveContactName(
                        todayBirthdayEvent!.birthdayContactIdentifier!
                    )

                    let age = ContactHelper.resolveBirthdate(
                        todayBirthdayEvent!.birthdayContactIdentifier!
                    )!.yearsAgo

                    Group {
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
                    }
                    .accessibilityLabel(
                        "It is \(name)'s birthday today. \(name) is now \(age) years old"
                    )

                } else {
                    let daysToGo: String = nextBirthdays.0.toDays
                    if nextBirthdays.1.count > 1 {
                        let birthdaysCount = nextBirthdays.1.count
                        Group {
                            Text(daysToGo)
                                .miniBadge(color: bCalColor)

                            Text("\(birthdaysCount)")
                                .hiddenIf(isSmall)
                        }
                        .accessibilityLabel(
                            "You have \(birthdaysCount) in \(daysToGo) days."
                        )
                    } else {
                        let people: String = nextBirthdays.1[0]
                        Group {
                            Text(daysToGo)
                                .miniBadge(color: bCalColor)
                            Text(people)
                                .hiddenIf(isSmall)
                        }
                        .accessibilityLabel(
                            "The next birthday is in \(daysToGo). It will be \(people)'s birthday."
                        )
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
