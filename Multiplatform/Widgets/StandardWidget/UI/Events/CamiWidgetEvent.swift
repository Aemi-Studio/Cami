//
//  CamiWidgetEvent.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 14/11/23.
//

import EventKit
import SwiftUI

struct CamiWidgetEvent: View {
    @Environment(\.data)
    private var data

    @Environment(\.widgetContent)
    private var content

    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.tint)
    private var tint

    @AppStorage(SettingsKeys.openInCami)
    private var openInPlace: Bool = UserDefaults.standard.bool(forKey: SettingsKeys.openInCami)

    private(set) var groupedItem: [CalendarItem]

    private var item: CalendarItem! {
        groupedItem.first
    }

    private var otherItems: ArraySlice<CalendarItem> {
        groupedItem.dropFirst()
    }

    private var isAllDay: Bool {
        item.isAllDay
    }

    private var shouldAppearBordered: Bool {
        content.configuration.allDayStyle == .bordered && isAllDay
    }

    private var tunedTint: some ShapeStyle {
        tint.quinary.opacity(colorScheme == .light ? 0.7 : 1)
    }

    @State private var eventSize = CGSize.zero

    @ViewBuilder
    private func actionable(
        for item: CalendarItem,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        if let data {
            if item.kind == .reminder {
                Button(intent: ReminderCompletionIntent(item.id)) {
                    content()
                }
                .buttonStyle(.plain)
            } else {
                Link(destination: data.destination(for: item, inPlace: openInPlace)) {
                    content()
                }
            }
        } else {
            content()
        }
    }

    var body: some View {
        actionable(for: item) {
            if item.kind == .reminder {
                HStack(spacing: 2.5) {
                    Circle()
                        .fill(.black)
                        .padding(1.75)
                        .frame(width: eventSize.height, height: eventSize.height)
                        .blendMode(.destinationOut)
                        .offset(x: -0.75)
                    mainBody
                        .update($eventSize)
                        .padding(.trailing, 2)
                }
            } else {
                mainBody
            }
        }
        .fontDesign(.rounded)
        .roundedBorder(bordered: shouldAppearBordered)
        .tinted(Color(cgColor: item.color))
        .clipShape(item.kind == .reminder ? AnyShape(.capsule) : AnyShape(.rect))
        .compositingGroup()
    }

    var mainBody: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(item.title)
                .font(.caption)
                .lineLimit(1)
                .accessibilityLabel(String(localized: "You have an event titled: \(item.title)."))
                .frame(maxWidth: .infinity, alignment: .leading)

            CalendarItemTime(items: groupedItem)
        }
    }
}
