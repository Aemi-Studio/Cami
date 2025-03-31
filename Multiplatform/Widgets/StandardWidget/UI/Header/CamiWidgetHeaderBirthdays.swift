//
//  CamiWidgetHeaderBirthdays.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 14/11/23.
//

import EventKit
import SwiftUI
import WidgetKit

struct CamiWidgetHeaderBirthdays: View {
    @Environment(\.data) private var data
    @Environment(\.widgetFamily) private var widgetFamily: WidgetFamily
    @Environment(\.customWidgetFamily) private var customWidgetFamily
    private var family: WidgetFamily { customWidgetFamily?.rawValue ?? widgetFamily }

    @Environment(\.widgetContent)
    private var content

    private var referenceDate: Date {
        content.date
    }

    private var birthdays: [CalendarItem] {
        content.birthdays.filter { $0.contactIdentifier != nil }.compactMap(\.self)
    }

    private var isSmall: Bool {
        family == .systemSmall
    }

    private let bCalColor: Color = .init(
        cgColor: DataContext.shared.birthdayCalendar?.cgColor
            ?? .init(red: 1, green: 0, blue: 0, alpha: 1)
    )

    private var todayBirthdayEvent: CalendarItem? {
        birthdays.first(where: \.isEndingToday)
    }

    private var nextBirthdays: (Int, [String]) {
        if let data, !birthdays.isEmpty {
            guard let firstBirthday = birthdays.first else {
                return (0, [])
            }

            var peopleBirthdays: [String] = birthdays.filter { event in
                event.isSameDay(as: firstBirthday) && event != firstBirthday
            }.compactMap { event in
                if let contact = event.contactIdentifier {
                    data.resolveContactName(contact)
                } else {
                    nil
                }
            }

            peopleBirthdays.insert(data.resolveContactName(firstBirthday.contactIdentifier!), at: 0)

            return (
                Int(firstBirthday.boundEnd.zero - referenceDate.zero),
                peopleBirthdays
            )
        } else {
            return (0, [])
        }
    }

    var body: some View {
        if let data {
            if let today = todayBirthdayEvent {
                birthdays(today, data: data)
                    .birthdayViewStyle(isSmall: isSmall, backgroundColor: bCalColor)
            } else if !birthdays.isEmpty, !nextBirthdays.1.isEmpty, let firstBirthday = birthdays.first {
                birthdays(firstBirthday, data: data)
                    .birthdayViewStyle(isSmall: isSmall, backgroundColor: bCalColor)
            }
        }
    }

    @ViewBuilder
    func birthdays(_ event: CalendarItem, data: DataContext) -> some View {
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
            todayBirthdayEvent!.contactIdentifier!
        )

        let age = data.resolveBirthdate(
            todayBirthdayEvent!.contactIdentifier!
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
        let daysToGo: String = Seconds.formattedDays(from: nextBirthdays.0)
        if nextBirthdays.1.count > 1 {
            let birthdaysCount = nextBirthdays.1.count
            Group {
                Text(daysToGo)
                    .miniBadge(color: bCalColor)

                if !isSmall {
                    Text(birthdaysCount, format: .number.precision(.integerAndFractionLength(integer: 1, fraction: 0)))
                }
            }
            .accessibilityLabel(String(localized: "You have \(birthdaysCount) in \(daysToGo) days."))
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

private extension View {
    func birthdayViewStyle(isSmall: Bool, backgroundColor: Color) -> some View {
        font(.caption)
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
