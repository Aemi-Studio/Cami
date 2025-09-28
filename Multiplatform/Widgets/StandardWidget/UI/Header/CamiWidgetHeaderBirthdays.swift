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

    private var birthdayViewModel: BirthdayViewModel? {
        guard let data else { return nil }
        return BirthdayViewModel(
            birthdays: content.birthdays,
            referenceDate: referenceDate,
            dataContext: data
        )
    }

    private var isSmall: Bool {
        family == .systemSmall
    }

    private let bCalColor: Color = .init(
        cgColor: DataContext.shared.birthdayCalendar?.cgColor
            ?? .init(red: 1, green: 0, blue: 0, alpha: 1)
    )

    var body: some View {
        if let viewModel = birthdayViewModel {
            if let todayEvent = viewModel.todayBirthdayEvent {
                birthdayView(for: todayEvent, viewModel: viewModel, isToday: true)
                    .birthdayViewStyle(isSmall: isSmall, backgroundColor: bCalColor)
            } else if !viewModel.validBirthdays.isEmpty,
                     !viewModel.nextBirthdaysInfo.names.isEmpty,
                     let firstBirthday = viewModel.validBirthdays.first {
                birthdayView(for: firstBirthday, viewModel: viewModel, isToday: false)
                    .birthdayViewStyle(isSmall: isSmall, backgroundColor: bCalColor)
            }
        }
    }

    @ViewBuilder
    func birthdayView(for event: CalendarItem, viewModel: BirthdayViewModel, isToday: Bool) -> some View {
        Link(destination: viewModel.dataContext.destination(for: event)) {
            HStack(alignment: .center, spacing: 4) {
                if isToday {
                    todaysBirthdayContent(event: event, viewModel: viewModel)
                } else {
                    futureBirthdaysContent(viewModel: viewModel)
                }
            }
        }
    }

    private func todaysBirthdayContent(event: CalendarItem, viewModel: BirthdayViewModel) -> some View {
        viewModel.birthdayInfo(for: event).map { info in
            Group {
                HStack(spacing: 0) {
                    if !isSmall {
                        Text("\(info.age)")
                    }

                    Label("\(info.age) years old", systemImage: "birthday.cake.fill")
                        .labelStyle(.iconOnly)
                        .font(.caption2)
                        .scaleEffect(0.8)
                        .lineSpacing(0)
                }
                .miniBadge(color: bCalColor)

                if !isSmall {
                    Text("\(info.name)")
                }
            }
            .accessibilityLabel(
                "It is \(info.name)'s birthday today. \(info.name) is now \(info.age) years old"
            )
        }
    }

    @ViewBuilder
    private func futureBirthdaysContent(viewModel: BirthdayViewModel) -> some View {
        let nextInfo = viewModel.nextBirthdaysInfo
        let daysToGo: String = Seconds.formattedDays(from: nextInfo.daysUntil)

        if nextInfo.names.count > 1 {
            let birthdaysCount = nextInfo.names.count
            Group {
                Text(daysToGo)
                    .miniBadge(color: bCalColor)

                if !isSmall {
                    Text(birthdaysCount, format: .number.precision(.integerAndFractionLength(integer: 1, fraction: 0)))
                }
            }
            .accessibilityLabel(String(localized: "You have \(birthdaysCount) in \(daysToGo) days."))
        } else if let firstPerson = nextInfo.names.first {
            Group {
                Text(daysToGo)
                    .miniBadge(color: bCalColor)

                if !isSmall {
                    Text(firstPerson)
                }
            }
            .accessibilityLabel(
                "The next birthday is in \(daysToGo). It will be \(firstPerson)'s birthday."
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
