//
//  DayPagerView.swift
//  Cami
//
//  Created by Guillaume Coquard on 26/11/25.
//

import SwiftUI

/// A horizontally scrolling pager that allows navigation between days with snapping behavior.
///
/// Optimized for memory efficiency by:
/// - Loading only ±30 days initially (vs ±365)
/// - Dynamically expanding range when approaching edges
/// - Prefetching data for adjacent days via CalendarStore
struct DayPagerView: View {
    @Environment(AppState.self) private var appState
    @Environment(DayStore.self) private var dayStore

    /// Top padding for header clearance
    let topPadding: CGFloat

    /// Initial range of days to pre-load around today
    private static let initialRange = 30

    /// How close to the edge before expanding the range
    private static let expansionThreshold = 7

    /// How many days to add when expanding
    private static let expansionAmount = 14

    /// Dynamic range that expands as user scrolls
    @State private var pastDays: Int = initialRange
    @State private var futureDays: Int = initialRange

    /// Scroll position binding to the current date
    @State private var scrollPosition: Date?

    /// Reference date for the pager (today)
    private var referenceDate: Date {
        Date.now.zero
    }

    /// Dates available for paging
    private var availableDates: [Date] {
        let calendar = Calendar.current
        return (-pastDays...futureDays).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: referenceDate)
        }
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                ForEach(availableDates, id: \.self) { date in
                    DayPageContent(date: date, topPadding: topPadding)
                        .id(date)
                        .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0.6)
                                .scaleEffect(phase.isIdentity ? 1 : 0.92)
                                .blur(radius: phase.isIdentity ? 0 : 2)
                        }
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

            // Update app state if date changed
            if newDate.zero != appState.selectedDate.zero {
                appState.navigateTo(date: newDate)

                // Update DayStore and trigger prefetch
                Task {
                    await dayStore.selectDate(newDate)
                    await CalendarStore.shared.prefetch(around: newDate, range: 3)
                }
            }

            // Expand range if approaching edges
            expandRangeIfNeeded(for: newDate)
        }
        .onChange(of: appState.selectedDate) { _, newDate in
            if scrollPosition?.zero != newDate.zero {
                // Ensure the date is within our range
                expandRangeToInclude(newDate)

                withAnimation(.easeInOut(duration: 0.3)) {
                    scrollPosition = newDate.zero
                }
            }
        }
    }

    /// Expands the date range if the user is approaching the edges
    private func expandRangeIfNeeded(for date: Date) {
        let calendar = Calendar.current
        guard let daysDiff = calendar.dateComponents([.day], from: referenceDate, to: date).day else {
            return
        }

        // Approaching past edge
        if daysDiff < 0 && abs(daysDiff) > pastDays - Self.expansionThreshold {
            pastDays += Self.expansionAmount
        }

        // Approaching future edge
        if daysDiff > 0 && daysDiff > futureDays - Self.expansionThreshold {
            futureDays += Self.expansionAmount
        }
    }

    /// Ensures the date is within our current range, expanding if necessary
    private func expandRangeToInclude(_ date: Date) {
        let calendar = Calendar.current
        guard let daysDiff = calendar.dateComponents([.day], from: referenceDate, to: date).day else {
            return
        }

        if daysDiff < 0 && abs(daysDiff) > pastDays {
            pastDays = abs(daysDiff) + Self.expansionThreshold
        }

        if daysDiff > 0 && daysDiff > futureDays {
            futureDays = daysDiff + Self.expansionThreshold
        }
    }
}

/// Content for a single day page, wrapping SingleDayView with vertical scrolling
private struct DayPageContent: View {
    @Environment(AppState.self) private var appState

    let date: Date
    let topPadding: CGFloat

    @State private var scrollOffset: CGFloat = 0
    @State private var dayContext: SingleDayContext?

    private var isCurrentPage: Bool {
        date.zero == appState.selectedDate.zero
    }

    var body: some View {
        ScrollOffsetReader($scrollOffset, showsIndicators: false) {
            if let context = dayContext {
                SingleDayView(context: context)
                    .padding(.horizontal)
                    .padding(.top, topPadding)
            } else {
                DayPagePlaceholder()
                    .padding(.horizontal)
                    .padding(.top, topPadding)
            }
        }
        .scrollClipDisabled()
        .containerRelativeFrame(.horizontal)
        .task {
            dayContext = SingleDayContext(for: date)
        }
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

/// Placeholder view shown while day content is loading
private struct DayPagePlaceholder: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 16) {
            // Summary placeholder
            HStack(spacing: 8) {
                ShimmerRectangle(cornerRadius: 8)
                    .frame(width: 80, height: 36)

                ShimmerRectangle(cornerRadius: 8)
                    .frame(width: 80, height: 36)

                Spacer()
            }
            .padding(.bottom, 18)

            // Event placeholders
            ForEach(0..<3, id: \.self) { index in
                HStack(spacing: 12) {
                    ShimmerRectangle(cornerRadius: 4)
                        .frame(width: 4, height: 44)

                    VStack(alignment: .leading, spacing: 4) {
                        ShimmerRectangle(cornerRadius: 4)
                            .frame(width: 120, height: 16)

                        ShimmerRectangle(cornerRadius: 4)
                            .frame(width: 80, height: 12)
                    }

                    Spacer()
                }
                .opacity(isAnimating ? 1 : 0.5)
                .animation(
                    .easeInOut(duration: 0.8)
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.1),
                    value: isAnimating
                )
            }

            Spacer()
        }
        .onAppear {
            isAnimating = true
        }
    }
}

/// A rectangle with shimmer effect for loading states
private struct ShimmerRectangle: View {
    let cornerRadius: CGFloat
    @State private var shimmerOffset: CGFloat = -1

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(.quaternary)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.3), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: shimmerOffset * 200)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                    shimmerOffset = 1
                }
            }
    }
}
