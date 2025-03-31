//
//  PreviewCalItemView.swift
//  Cami
//
//  Created by Guillaume Coquard on 21/03/25.
//

import Combine
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
            showDetail.toggle()
        } label: {
            content
                .padding()
                .background(
                    GlassStyle(.rect(cornerRadius: 12), color: Color(item.calendar.cgColor), intensity: 0.05)
                )
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .animation(.interactiveSpring, value: showDetail)
    }

    @ViewBuilder var content: some View {
        VStack(alignment: .leading, spacing: 4) {
            Group {
                HStack {
                    CalendarItemCalendarColorBadge(item: item)
                    CalendarItemStartDateView(date: startDate, isAllDay: isAllDay)
                    if !showDetail {
                        Spacer()
                        CalendarItemCharacteristicsView(event: item)
                    }
                }
                Text(item.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)

                if showDetail {
                    CalendarItemDetailView(event: item)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .fontDesign(.rounded)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
                Label("Location", systemImage: "mappin.circle.fill")
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
                Label("Attendees", systemImage: "person.3.fill")
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
            Label("Location", systemImage: "mappin.circle.fill")
        }
    }
}

struct CalendarItemCallUrlBadge: View {
    let event: EKCalendarItem

    var body: some View {
        if event.url != nil {
            Label("Call", systemImage: "phone.fill")
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
