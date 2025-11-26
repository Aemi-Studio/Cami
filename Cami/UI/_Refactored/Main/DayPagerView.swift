//
//  DayPagerView.swift
//  Cami
//
//  Created by Guillaume Coquard on 26/11/25.
//

import SwiftUI

/// A horizontally scrolling pager that allows navigation between days with snapping behavior.
struct DayPagerView: View {
    @Environment(AppState.self) private var appState

    /// Top padding for header clearance
    let topPadding: CGFloat

    /// Range of days to pre-load around the current selection
    private let preloadRange = -365...365

    /// Scroll position binding to the current date
    @State private var scrollPosition: Date?

    /// Dates available for paging (centered around today)
    private var availableDates: [Date] {
        let calendar = Calendar.current
        let today = Date.now.zero
        return preloadRange.compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: today)
        }
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                ForEach(availableDates, id: \.self) { date in
                    DayPageContent(date: date, topPadding: topPadding)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $scrollPosition)
        .scrollClipDisabled()
        .onAppear {
            scrollPosition = appState.selectedDate.zero
        }
        .onChange(of: scrollPosition) { _, newPosition in
            guard let newDate = newPosition else { return }
            if newDate.zero != appState.selectedDate.zero {
                appState.navigateTo(date: newDate)
            }
        }
        .onChange(of: appState.selectedDate) { _, newDate in
            if scrollPosition?.zero != newDate.zero {
                withAnimation(.easeInOut(duration: 0.3)) {
                    scrollPosition = newDate.zero
                }
            }
        }
    }
}

/// Content for a single day page, wrapping SingleDayView with vertical scrolling
private struct DayPageContent: View {
    @Environment(AppState.self) private var appState

    let date: Date
    let topPadding: CGFloat

    @State private var scrollOffset: CGFloat = 0

    private var isCurrentPage: Bool {
        date.zero == appState.selectedDate.zero
    }

    var body: some View {
        ScrollOffsetReader($scrollOffset, showsIndicators: false) {
            SingleDayView(context: appState.dayContext(for: date))
                .padding(.horizontal)
                .padding(.top, topPadding)
        }
        .scrollClipDisabled()
        .containerRelativeFrame(.horizontal)
        .onChange(of: scrollOffset) { _, newOffset in
            if isCurrentPage {
                appState.currentScrollOffset = newOffset
            }
        }
        .onChange(of: isCurrentPage) { _, isCurrent in
            if isCurrent {
                appState.currentScrollOffset = scrollOffset
            }
        }
    }
}
