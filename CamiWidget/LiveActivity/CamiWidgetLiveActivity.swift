//
//  CamiWidgetLiveActivity.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 03/11/23.
//

import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Live Activity Widget

struct OngoingEventLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: OngoingEventAttributes.self) { context in
            // Lock Screen / Banner presentation
            LockScreenView(context: context)
                .activityBackgroundTint(eventColor(from: context.attributes).opacity(0.2))
                .activitySystemActionForegroundColor(eventColor(from: context.attributes))
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded presentation
                DynamicIslandExpandedRegion(.leading) {
                    ExpandedLeadingView(context: context)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    ExpandedTrailingView(context: context)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedBottomView(context: context)
                }
                DynamicIslandExpandedRegion(.center) {
                    ExpandedCenterView(context: context)
                }
            } compactLeading: {
                CompactLeadingView(context: context)
            } compactTrailing: {
                CompactTrailingView(context: context)
            } minimal: {
                MinimalView(context: context)
            }
            .widgetURL(URL(string: "camical://event/\(context.attributes.eventIdentifier)"))
            .keylineTint(eventColor(from: context.attributes))
        }
    }

    private func eventColor(from attributes: OngoingEventAttributes) -> Color {
        Color(
            red: attributes.colorRed,
            green: attributes.colorGreen,
            blue: attributes.colorBlue
        )
    }
}

// MARK: - Lock Screen View

private struct LockScreenView: View {
    let context: ActivityViewContext<OngoingEventAttributes>

    private var eventColor: Color {
        Color(
            red: context.attributes.colorRed,
            green: context.attributes.colorGreen,
            blue: context.attributes.colorBlue
        )
    }

    var body: some View {
        HStack(spacing: 12) {
            // Progress indicator
            ProgressCircle(
                progress: context.state.progress,
                lineWidthRatio: 0.15
            )
            .frame(width: 44, height: 44)
            .tint(eventColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(context.attributes.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    if let location = context.attributes.location, !location.isEmpty {
                        Label(location, systemImage: "location.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Label {
                        Text(timerInterval: context.attributes.startDate...context.attributes.endDate,
                             countsDown: true)
                    } icon: {
                        Image(systemName: "clock")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // End time
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(localized: "liveActivity.endsAt"))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Text(context.attributes.endDate, style: .time)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(eventColor)
            }
        }
        .padding()
    }
}

// MARK: - Dynamic Island Expanded Views

private struct ExpandedLeadingView: View {
    let context: ActivityViewContext<OngoingEventAttributes>

    private var eventColor: Color {
        Color(
            red: context.attributes.colorRed,
            green: context.attributes.colorGreen,
            blue: context.attributes.colorBlue
        )
    }

    var body: some View {
        ProgressCircle(
            progress: context.state.progress,
            lineWidthRatio: 0.2
        )
        .frame(width: 28, height: 28)
        .tint(eventColor)
    }
}

private struct ExpandedTrailingView: View {
    let context: ActivityViewContext<OngoingEventAttributes>

    private var eventColor: Color {
        Color(
            red: context.attributes.colorRed,
            green: context.attributes.colorGreen,
            blue: context.attributes.colorBlue
        )
    }

    var body: some View {
        Text(context.attributes.endDate, style: .time)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(eventColor)
    }
}

private struct ExpandedCenterView: View {
    let context: ActivityViewContext<OngoingEventAttributes>

    var body: some View {
        Text(context.attributes.title)
            .font(.subheadline)
            .fontWeight(.semibold)
            .lineLimit(1)
    }
}

private struct ExpandedBottomView: View {
    let context: ActivityViewContext<OngoingEventAttributes>

    var body: some View {
        HStack {
            if let location = context.attributes.location, !location.isEmpty {
                Label(location, systemImage: "location.fill")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Text(timerInterval: context.attributes.startDate...context.attributes.endDate,
                 countsDown: true)
            .font(.caption2)
            .fontWeight(.medium)
            .monospacedDigit()
            .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Dynamic Island Compact Views

private struct CompactLeadingView: View {
    let context: ActivityViewContext<OngoingEventAttributes>

    private var eventColor: Color {
        Color(
            red: context.attributes.colorRed,
            green: context.attributes.colorGreen,
            blue: context.attributes.colorBlue
        )
    }

    var body: some View {
        ProgressCircle(
            progress: context.state.progress,
            lineWidthRatio: 0.25
        )
        .frame(width: 20, height: 20)
        .tint(eventColor)
    }
}

private struct CompactTrailingView: View {
    let context: ActivityViewContext<OngoingEventAttributes>

    var body: some View {
        Text(timerInterval: context.attributes.startDate...context.attributes.endDate,
             countsDown: true)
        .font(.caption2)
        .fontWeight(.medium)
        .monospacedDigit()
        .frame(minWidth: 32)
    }
}

// MARK: - Dynamic Island Minimal View

private struct MinimalView: View {
    let context: ActivityViewContext<OngoingEventAttributes>

    private var eventColor: Color {
        Color(
            red: context.attributes.colorRed,
            green: context.attributes.colorGreen,
            blue: context.attributes.colorBlue
        )
    }

    var body: some View {
        ProgressCircle(
            progress: context.state.progress,
            lineWidthRatio: 0.25
        )
        .tint(eventColor)
    }
}

// MARK: - Previews

#Preview("Lock Screen", as: .content, using: OngoingEventAttributes.preview) {
    OngoingEventLiveActivity()
} contentStates: {
    OngoingEventAttributes.ContentState.inProgress
    OngoingEventAttributes.ContentState.almostDone
}

#Preview("Dynamic Island Compact", as: .dynamicIsland(.compact), using: OngoingEventAttributes.preview) {
    OngoingEventLiveActivity()
} contentStates: {
    OngoingEventAttributes.ContentState.inProgress
}

#Preview("Dynamic Island Expanded", as: .dynamicIsland(.expanded), using: OngoingEventAttributes.preview) {
    OngoingEventLiveActivity()
} contentStates: {
    OngoingEventAttributes.ContentState.inProgress
}

#Preview("Dynamic Island Minimal", as: .dynamicIsland(.minimal), using: OngoingEventAttributes.preview) {
    OngoingEventLiveActivity()
} contentStates: {
    OngoingEventAttributes.ContentState.inProgress
}

// MARK: - Preview Data

extension OngoingEventAttributes {
    static var preview: OngoingEventAttributes {
        OngoingEventAttributes(
            eventIdentifier: "preview-event",
            title: "Team Standup Meeting",
            location: "Conference Room A",
            startDate: Date.now.addingTimeInterval(-1800), // Started 30 min ago
            endDate: Date.now.addingTimeInterval(1800), // Ends in 30 min
            color: (red: 0.2, green: 0.5, blue: 1.0),
            isAllDay: false
        )
    }
}

extension OngoingEventAttributes.ContentState {
    static var inProgress: OngoingEventAttributes.ContentState {
        OngoingEventAttributes.ContentState(progress: 0.5, hasEnded: false)
    }

    static var almostDone: OngoingEventAttributes.ContentState {
        OngoingEventAttributes.ContentState(progress: 0.9, hasEnded: false)
    }
}
