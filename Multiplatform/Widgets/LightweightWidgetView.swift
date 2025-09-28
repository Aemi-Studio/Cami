//
//  LightweightWidgetView.swift
//  Cami
//
//  Created by Guillaume Coquard on 28/09/25.
//

import AemiUI
import SwiftUI

struct LightweightWidgetView: View {
    typealias Entry = StandardWidgetEntry
    typealias Content = LightweightWidgetContent

    private let content: Content

    private var showHeader: Bool { content.configuration.showHeader }

    private var background: some ShapeStyle {
        AnyShapeStyle(Color.background.opacity(0.9))
    }

    init(for entry: Entry) {
        self.content = Content(from: entry)
    }

    var body: some View {
        VStack(spacing: 6) {
            if showHeader {
                LightweightWidgetHeader()
            }
            Color.clear.overlay(alignment: .top) {
                LightweightWidgetEvents()
                    .frame(alignment: .top)
                    .padding(.top, showHeader ? 0 : 6)
            }
            Spacer(minLength: 0)
        }
        .padding([.top, .horizontal], 6)
        .accessibilityAddTraits(.updatesFrequently)
        .mask(GradientMask.init)
        .widgetAccentable()
        .containerBackground(background, for: .widget)
        .environment(\.lightweightWidgetContent, content)
        .environment(\.data, .shared)
        .environment(\.locale, .prefered)
        .task { DataContext.shared.subscribe() }
    }
}

// MARK: - Environment Values for Lightweight Widget

extension EnvironmentValues {
    @Entry var lightweightWidgetContent: LightweightWidgetContent = .init(from: .default)
}

// MARK: - Lightweight Widget Components

struct LightweightWidgetHeader: View {
    @Environment(\.lightweightWidgetContent)
    private var content

    var body: some View {
        HStack {
            Text("Today")
                .font(.headline)
                .foregroundColor(.primary)

            Spacer()

            if !content.birthdays.isEmpty {
                Image(systemName: "gift")
                    .foregroundColor(.orange)
            }
        }
        .padding(.horizontal, 4)
    }
}

struct LightweightWidgetEvents: View {
    @Environment(\.lightweightWidgetContent)
    private var content

    var body: some View {
        LazyVStack(spacing: 2) {
            ForEach(sortedDates, id: \.self) { date in
                LightweightDaySection(items: content.items[date] ?? [])
            }
        }
    }

    private var sortedDates: [Date] {
        Array(content.items.keys).sorted()
    }
}

struct LightweightDaySection: View {
    let items: [WidgetCalendarItem]

    var body: some View {
        VStack(spacing: 1) {
            ForEach(items.prefix(3), id: \.id) { item in
                LightweightEventRow(item: item)
            }
        }
    }
}

struct LightweightEventRow: View {
    let item: WidgetCalendarItem

    var body: some View {
        HStack {
            Circle()
                .fill(colorForItem)
                .frame(width: 6, height: 6)

            Text(item.title)
                .font(.caption)
                .lineLimit(1)
                .foregroundColor(.primary)

            Spacer()

            if let startDate = item.startDate {
                Text(timeFormatter.string(from: startDate))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 1)
    }

    private var colorForItem: Color {
        // Simple color mapping based on colorIndex
        switch item.colorIndex % 6 {
        case 0: return .blue
        case 1: return .green
        case 2: return .orange
        case 3: return .red
        case 4: return .purple
        default: return .gray
        }
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}
