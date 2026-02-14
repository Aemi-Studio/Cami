import SwiftUI
import WidgetKit

struct CamiWidget: Widget {
    private let kind = "CamiWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: CamiWidgetIntent.self, provider: CamiWidgetProvider()) { entry in
            CamiWidgetView(entry: entry)
        }
        .configurationDisplayName("Cami")
        .description("Widgets-first timeline for events, reminders, and birthdays.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
        .containerBackgroundRemovable()
        .contentMarginsDisabled()
    }
}

private struct CamiWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: StandardWidgetEntry

    private var maxRows: Int {
        switch family {
        case .systemSmall:
            4
        case .systemMedium:
            8
        case .systemLarge:
            12
        case .systemExtraLarge:
            18
        default:
            8
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if entry.configuration.showHeader {
                header
            }

            if entry.sections.isEmpty {
                Text("No items")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                sectionList
            }
        }
        .padding(10)
        .containerBackground(.background.opacity(0.9), for: .widget)
        .widgetAccentable()
    }

    private var header: some View {
        HStack(spacing: 8) {
            Text(entry.date, format: .dateTime.weekday(.abbreviated).day())
                .font(.headline.weight(.bold))
                .lineLimit(1)

            Spacer(minLength: 0)

            CamiWidgetCreateEventButton()

            switch entry.configuration.complication {
            case .hidden:
                EmptyView()
            case .birthdays:
                Text(entry.birthdayCount, format: .number)
                    .font(.caption.bold())
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(.pink.opacity(0.2), in: Capsule())
                    .accessibilityLabel("\(entry.birthdayCount) birthdays in the visible range")
            case .summary:
                Text(visibleEventCount, format: .number)
                    .font(.caption.bold())
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(.red.opacity(0.2), in: Capsule())
                    .accessibilityLabel("\(visibleEventCount) timed events")
            }
        }
    }

    private var sectionList: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(entry.sections.prefix(2)) { section in
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(section.date, format: .dateTime.weekday(.abbreviated).day())
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)

                        Spacer(minLength: 0)

                        if section.inlineAllDayCount > 0 {
                            Text("All-day \(section.inlineAllDayCount)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }

                    ForEach(section.items.prefix(maxRows)) { item in
                        CamiWidgetRow(item: item, allDayStyle: entry.configuration.allDayStyle)
                    }
                }
            }
        }
    }

    private var visibleEventCount: Int {
        entry.sections
            .flatMap(\.items)
            .filter { $0.kind == .event && !$0.isAllDay && Calendar.current.isDateInToday($0.startDate) }
            .count
    }
}

private struct CamiWidgetRow: View {
    let item: WidgetTimelineItem
    let allDayStyle: AllDayStyleEnum

    private var rowBackground: some ShapeStyle {
        if allDayStyle == .bordered && item.isAllDay {
            return AnyShapeStyle(Color(.systemBackground))
        }
        return AnyShapeStyle(.clear)
    }

    private var rowBorder: Color {
        if allDayStyle == .bordered && item.isAllDay {
            return color.opacity(0.35)
        }
        return .clear
    }

    private var color: Color {
        Color(hex: item.colorHex)
    }

    private var destinationURL: URL {
        switch item.kind {
        case .event, .birthday:
            return URL(string: "camical://event/\(item.id)")!
        case .reminder:
            return URL(string: "camical://reminder/\(item.id)")!
        }
    }

    var body: some View {
        Group {
            if item.kind == .reminder {
                Button(intent: ReminderCompletionIntent(item.id)) {
                    rowContent
                }
                .buttonStyle(.plain)
            } else {
                Link(destination: destinationURL) {
                    rowContent
                }
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(rowBackground, in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(rowBorder, lineWidth: 1)
        }
    }

    private var rowContent: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
                .accessibilityHidden(true)

            Text(item.displayTitle)
                .font(.caption)
                .lineLimit(1)

            Spacer(minLength: 0)

            Text(timeText)
                .font(.caption2.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.displayTitle), \(timeText)")
    }

    private var timeText: String {
        if item.isAllDay {
            return String(localized: "All-day")
        }
        return item.startDate.formatted(date: .omitted, time: .shortened)
    }
}

private struct CamiWidgetCreateEventButton: View {
    var body: some View {
        Link(destination: URL(string: "camical://create/event")!) {
            Label("Create event", systemImage: "plus")
                .labelStyle(.iconOnly)
                .font(.caption.bold())
                .padding(5)
                .background(.secondary.opacity(0.2), in: RoundedRectangle(cornerRadius: 7))
        }
        .accessibilityLabel("Create event or reminder")
    }
}

private extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        let red = Double((value & 0xFF0000) >> 16) / 255
        let green = Double((value & 0x00FF00) >> 8) / 255
        let blue = Double(value & 0x0000FF) / 255
        self.init(red: red, green: green, blue: blue)
    }
}
