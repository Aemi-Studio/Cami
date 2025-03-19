//
//  CamiWidgetHeaderEventSummary.swift
//  CamiWidgetExtension
//
//  Created by Guillaume Coquard on 11/09/24.
//

import EventKit
import SwiftUI
import WidgetKit

struct CamiWidgetHeaderEventSummary: View {

    @Environment(\.widgetFamily) private var widgetFamily
    @Environment(\.customWidgetFamily) private var customWidgetFamily
    private var family: WidgetFamily { customWidgetFamily?.rawValue ?? widgetFamily }

    @Environment(\.widgetContent)   private var content

    private var isSmall: Bool {
        family == .systemSmall
    }

    private var numberOfEvents: Int {
        let today = Date.now.zero

        guard content.items.keys.contains(today), let events = content.items[today]
        else { return 0 }

        return events.filter { event in
            if event.kind == .event {
                event.isStartingToday && event.isEndingToday && !event.isAllDay
            } else {
                false
            }
        }.count
    }

    private var noEvents: Bool {
        numberOfEvents == 0
    }

    private var foregroundStyle: some ShapeStyle {
        noEvents
            ? AnyShapeStyle(Color.primary.tertiary)
            : AnyShapeStyle(Color.white)
    }

    private var backgroundStyle: Color {
        noEvents
            ? .clear
            : .red.opacity(0.6)
    }

    private var text: Text {
        Text(
            noEvents
                ? String(localized: "noEventToday.complication")
                : "\(numberOfEvents)"
        )
    }

    var body: some View {
        HStack(alignment: .center, spacing: 3) {
            if !noEvents {
                Image(systemName: "circle.fill")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 4, height: 4)
            }
            text
        }
        .font(.footnote)
        .fontWeight(.bold)
        .fontWidth(.compressed)
        .pad([
            .notSmall: .init(top: 4, leading: 4, bottom: 4, trailing: 6),
            .systemSmall: .init(all: 0)
        ])
        .background(backgroundStyle)
        .foregroundStyle(foregroundStyle)
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
