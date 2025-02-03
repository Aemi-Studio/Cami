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
    @Environment(\.widgetFamily)
    private var widgetFamily: WidgetFamily

    @Environment(CamiWidgetEntry.self)
    private var entry: CamiWidgetEntry

    private var isSmall: Bool {
        widgetFamily == WidgetFamily.systemSmall
    }

    var numberOfEvents: Int {
        let today = Date.now.zero
        if entry.events.keys.contains(Date.now.zero) {
            guard let events = entry.events[today] else { return 0 }
            return events.filter {
                if let event = $0 as? EKEvent {
                    event.isStartingToday && event.isEndingToday && !event.isAllDay
                } else {
                    false
                }
            }.count
        } else {
            return 0
        }
    }

    var text: some View {
        var text: String

        if numberOfEvents < 1 {
            text = NSLocalizedString("noEventToday.complication", comment: "")
        } else {
            text = "\(numberOfEvents)"
        }

        return Text(text)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 3) {
            if numberOfEvents > 0 {
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
        .background(numberOfEvents == 0 ? .clear : .red.opacity(0.6))
        .foregroundStyle(
            numberOfEvents == 0
                ? AnyShapeStyle(Color.primary.tertiary)
                : AnyShapeStyle(Color.white)
        )
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
