//
//  PreviewCalItemView.swift
//  Cami
//
//  Created by Guillaume Coquard on 21/03/25.
//

import EventKit
import MapKit
import SwiftUI

struct CalendarItemView: View {
    let item: EKCalendarItem

    @Namespace private var localNamespace

    private var startDate: Date? {
        switch item {
            case is EKEvent: (item as? EKEvent)?.startDate
            case is EKReminder: (item as? EKReminder)?.dueDateComponents?.date
            default: nil
        }
    }

    private var isAllDay: Bool? {
        if let event = item as? EKEvent {
            event.isAllDay
        } else {
            false
        }
    }

    @State private var showDetail = false

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                showDetail.toggle()
            }
        } label: {
            content
                .padding()
                .background(
                    GlassStyle(.rect(cornerRadius: 12), color: Color(item.calendar.cgColor), intensity: 0.05)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(item.calendar.cgColor).opacity(showDetail ? 0.3 : 0), lineWidth: 1)
                }
                .contentShape(.rect)
        }
        .buttonStyle(ScaleButtonStyle())
        .sensoryFeedback(.selection, trigger: showDetail)
    }

    @ViewBuilder private var content: some View {
        VStack(alignment: .leading, spacing: 4) {
            Group {
                HStack {
                    CalendarItemCalendarColorBadge(item: item)
                        .scaleEffect(showDetail ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showDetail)

                    CalendarItemStartDateView(date: startDate, isAllDay: isAllDay)

                    if !showDetail {
                        Spacer()
                        CalendarItemCharacteristicsView(event: item)
                            .transition(.opacity.combined(with: .scale(scale: 0.8)))
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showDetail)

                Text(item.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)

                if showDetail {
                    CalendarItemDetailView(event: item)
                        .transition(
                            .asymmetric(
                                insertion: .opacity
                                    .combined(with: .move(edge: .top))
                                    .combined(with: .scale(scale: 0.95, anchor: .top)),
                                removal: .opacity
                                    .combined(with: .scale(scale: 0.95, anchor: .top))
                            )
                        )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .fontDesign(.rounded)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A button style that provides subtle scale feedback without interfering with scroll gestures
private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct CalendarItemDetailView: View {
    let event: EKCalendarItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            CalendarItemLocationDetailView(event: event)
            CalendarItemAttendeesDetailView(event: event)
        }
        .padding(.top, 4)
    }
}

struct CapsuleDivider: View {
    private(set) var color: Color = .primary

    var body: some View {
        Capsule()
            .fill(color.quaternary)
            .frame(height: 0.5)
    }
}

// MARK: - Location

struct Detail<Header: View, Content: View>: View {
    private let color: Color
    private let header: () -> Header
    private let content: () -> Content

    @State private var isShown = false

    init(
        color: Color = Color.primary,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.color = color
        self.header = header
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                header()
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.primary.tertiary)
                    .textCase(.uppercase)
                Spacer()
                ShowHideButton(isShown: $isShown)
            }
            content()
                .font(.body)
                .foregroundStyle(.secondary)
                .opacity(isShown ? 1 : 0)
                .blur(radius: isShown ? 0 : 3)
                .frame(maxHeight: isShown ? nil : 0)
                .clipped()
                .animation(.default, value: isShown)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, isShown ? 0 : -6)
        .animation(.default.delay(0.1), value: isShown)
    }
}

struct ShowHideButton: View {
    @Binding var isShown: Bool

    var body: some View {
        Button {
            isShown.toggle()
        } label: {
            Text(
                isShown
                    ? String(localized: "button.showHide.hide")
                    : String(localized: "button.showHide.show")
            )
            .foregroundStyle(.black)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .font(.caption2)
            .fontWeight(.semibold)
            .textCase(.uppercase)
            .blendMode(.destinationOut)
        }
        .buttonStyle(.plain)
        .background(Color.primary.tertiary)
        .clipShape(Capsule())
        .animation(.default, value: isShown)
        .compositingGroup()
    }
}

struct CalendarItemLocationDetailView: View {
    let event: EKCalendarItem

    private var color: Color {
        Color(event.calendar.cgColor)
    }

    var body: some View {
        if let location = event.location {
            CapsuleDivider(color: color).padding(.vertical, 4)
            Detail(color: color) {
                Label(String(localized: "label.location"), systemImage: "mappin.circle.fill")
            } content: {
                Text(location)
            }
        }
    }
}

// MARK: - Attendees

struct CalendarItemAttendeesDetailView: View {
    let event: EKCalendarItem

    private var color: Color {
        Color(event.calendar.cgColor)
    }

    var body: some View {
        if let attendees = event.attendees {
            CapsuleDivider(color: color).padding(.vertical, 4)
            Detail(color: color) {
                Label(String(localized: "label.attendees"), systemImage: "person.3.fill")
            } content: {
                Text(attendees.compactMap(\.name).joined(separator: ", "))
            }
        }
    }
}

// HStack for badges (location, call url, ...)
struct CalendarItemCharacteristicsView: View {
    let event: EKCalendarItem

    var body: some View {
        HStack(spacing: 4) {
            CalendarItemLocationBadge(event: event)
            CalendarItemCallUrlBadge(event: event)
        }
        .labelStyle(.iconOnly)
        .font(.caption)
        .foregroundStyle(.secondary)
    }
}

struct CalendarItemLocationBadge: View {
    let event: EKCalendarItem

    var body: some View {
        if event.location != nil {
            Label(String(localized: "label.location"), systemImage: "mappin.circle.fill")
        }
    }
}

struct CalendarItemCallUrlBadge: View {
    let event: EKCalendarItem

    var body: some View {
        if event.url != nil {
            Label(String(localized: "label.call"), systemImage: "phone.fill")
        }
    }
}

struct CalendarItemStartDateView: View {
    let date: Date?
    let isAllDay: Bool?

    var body: some View {
        if let isAllDay, isAllDay {
            HStack {
                Text(String(localized: "item.detail.isAllDay"))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .textCase(.uppercase)
                    .blendMode(.destinationOut)
            }
            .background(Color.primary.tertiary)
            .clipShape(Capsule())
            .compositingGroup()
        } else if let date {
            Text(date, format: .dateTime.hour().minute())
                .font(.callout)
                .foregroundStyle(Color.secondary)
        }
    }
}
