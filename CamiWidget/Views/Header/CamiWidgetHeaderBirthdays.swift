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

    @Environment(\.data) private var data
    @Environment(\.widgetFamily) private var widgetFamily
    @Environment(CamiWidgetEntry.self) private var entry

    private var birthdays: CItems {
        entry.birthdays
    }

    private var isSmall: Bool {
        widgetFamily == WidgetFamily.systemSmall
    }

    private let bCalColor: Color = Color(
        cgColor: DataContext.shared.birthdayCalendar?.cgColor
            ?? .init(red: 1, green: 0, blue: 0, alpha: 1)
    )

    private var todayBirthdayEvent: EKEvent? {
        return birthdays.first(where: { event in event.isEndingToday }) as? EKEvent
    }

    private var nextBirthdays: (Seconds, [String]) {
        if let data, birthdays.count > 0 {
            let firstBirthday: EKEvent = birthdays[0] as! EKEvent // swiftlint:disable:this force_cast

            var peopleBirthdays: [String] = birthdays.filter { event in
                event.isSameDay(as: firstBirthday) && event != firstBirthday
            }.compactMap { event in
                if let event = event as? EKEvent {
                    data.resolveContactName(
                        event.birthdayContactIdentifier!
                    )
                } else {
                    nil
                }
            }

            peopleBirthdays.insert(
                data.resolveContactName(
                    firstBirthday.birthdayContactIdentifier!
                ),
                at: 0
            )

            return (
                Int(firstBirthday.endingDate.zero - entry.date.zero) as Seconds,
                peopleBirthdays
            )
        } else {
            return (0 as Seconds, [])
        }
    }

    var body: some View {
        if let data, !entry.birthdays.isEmpty && nextBirthdays.1.count > 0 {
            if let firstBirthday = birthdays.first as? EKEvent {
                birthdays(firstBirthday, data: data)
                    .birthdayViewStyle(isSmall: isSmall, backgroundColor: bCalColor)
            }
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    func birthdays(_ event: EKEvent, data: DataContext) -> some View {
        Link(destination: data.destination(for: event)) {
            HStack(alignment: .center, spacing: 4) {
                if todayBirthdayEvent != nil {
                    forTodaysBirthday(data)
                } else {
                    forFutureBirthdays()
                }
            }
        }
    }

    @ViewBuilder
    private func forTodaysBirthday(_ data: DataContext) -> some View {
        let name = data.resolveContactName(
            todayBirthdayEvent!.birthdayContactIdentifier!
        )

        let age = data.resolveBirthdate(
            todayBirthdayEvent!.birthdayContactIdentifier!
        )!.yearsAgo

        Group {
            HStack(spacing: 0) {

                if !isSmall {
                    Text("\(age)")
                }

                Label("\(age) years old", systemImage: "birthday.cake.fill")
                    .labelStyle(.iconOnly)
                    .font(.caption2)
                    .scaleEffect(0.8)
                    .lineSpacing(0)
            }
            .miniBadge(color: bCalColor)

            if !isSmall {
                Text("\(name)")
            }
        }
        .accessibilityLabel(
            "It is \(name)'s birthday today. \(name) is now \(age) years old"
        )
    }

    @ViewBuilder
    private func forFutureBirthdays() -> some View {
        let daysToGo: String = nextBirthdays.0.toDays
        if nextBirthdays.1.count > 1 {
            let birthdaysCount = nextBirthdays.1.count
            Group {
                HStack {
                    Text(daysToGo)
                }
                .miniBadge(color: bCalColor)

                if !isSmall {
                    Text("\(birthdaysCount)")
                }
            }
            .accessibilityLabel(
                "You have \(birthdaysCount) in \(daysToGo) days."
            )
        } else {
            let people: String = nextBirthdays.1[0]
            Group {
                Text(daysToGo)
                    .miniBadge(color: bCalColor)

                if !isSmall {
                    Text(people)
                }
            }
            .accessibilityLabel(
                "The next birthday is in \(daysToGo). It will be \(people)'s birthday."
            )
        }
    }
}

fileprivate extension View {
    func birthdayViewStyle(isSmall: Bool, backgroundColor: Color) -> some View {
        self
            .font(.caption)
            .fontWeight(.bold)
            .fontWidth(.compressed)
            .pad([
                .notSmall: .init(top: 4, leading: 4, bottom: 4, trailing: 6),
                .systemSmall: .init(all: 0)
            ])
            .background(isSmall ? .clear : backgroundColor.opacity(0.1))
            .foregroundStyle(backgroundColor)
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
    }
}
