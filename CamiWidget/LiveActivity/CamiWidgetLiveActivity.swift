import ActivityKit
import SwiftUI
import WidgetKit

struct OngoingEventAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var progress: Double
        var hasEnded: Bool
    }

    var eventIdentifier: String
    var title: String
    var location: String?
    var startDate: Date
    var endDate: Date
    var colorRed: Double
    var colorGreen: Double
    var colorBlue: Double
    var isAllDay: Bool
}

struct OngoingEventLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: OngoingEventAttributes.self) { context in
            LockScreenLiveActivityView(context: context)
                .activityBackgroundTint(eventColor(context.attributes).opacity(0.2))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    ProgressView(value: max(0, min(1, context.state.progress)))
                        .progressViewStyle(.circular)
                        .tint(eventColor(context.attributes))
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.attributes.endDate, style: .time)
                        .font(.caption)
                }

                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.title)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        if let location = context.attributes.location, !location.isEmpty {
                            Label(location, systemImage: "mappin")
                                .lineLimit(1)
                        }
                        Spacer()
                        Text(timerInterval: context.attributes.startDate...context.attributes.endDate, countsDown: true)
                            .monospacedDigit()
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
            } compactLeading: {
                Image(systemName: "calendar")
                    .foregroundStyle(eventColor(context.attributes))
            } compactTrailing: {
                Text(timerInterval: context.attributes.startDate...context.attributes.endDate, countsDown: true)
                    .font(.caption2)
                    .monospacedDigit()
            } minimal: {
                Image(systemName: "calendar")
            }
            .widgetURL(URL(string: "camical://event/\(context.attributes.eventIdentifier)"))
        }
    }

    private func eventColor(_ attributes: OngoingEventAttributes) -> Color {
        Color(red: attributes.colorRed, green: attributes.colorGreen, blue: attributes.colorBlue)
    }
}

private struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<OngoingEventAttributes>

    var body: some View {
        HStack(spacing: 12) {
            ProgressView(value: max(0, min(1, context.state.progress)))
                .progressViewStyle(.circular)
                .tint(.accentColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(context.attributes.title)
                    .font(.headline)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    if let location = context.attributes.location, !location.isEmpty {
                        Label(location, systemImage: "mappin.circle")
                            .lineLimit(1)
                    }
                    Text(timerInterval: context.attributes.startDate...context.attributes.endDate, countsDown: true)
                        .monospacedDigit()
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Text(context.attributes.endDate, style: .time)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }
}
