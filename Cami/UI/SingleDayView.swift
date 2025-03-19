//
//  SingleDayView.swift
//  Cami
//
//  Created by Guillaume Coquard on 23/01/25.
//

import Combine
import EventKit
import SwiftUI
import WidgetKit

struct SingleDayView: View {
    @Environment(\.presentation) private var presentation
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // iOS-driven data
    private var topSafeAreaHeight: CGFloat { UIApplication.currentWindow?.safeAreaInsets.top ?? 0 }

    private let topBarHeight = 48.0
    private let minimizedTopBarHeight = 32.0

    @State  private var visibilityAmount: CGFloat = 1
    private var effectiveTopBarHeight: CGFloat {
        let initialHeight = topBarHeight
        let difference = topBarHeight - minimizedTopBarHeight
        return initialHeight - difference * (1 - visibilityAmount)
    }
    private var effectiveBlurHeight: CGFloat { topSafeAreaHeight + (1 - visibilityAmount) * topBarHeight }
    private var effectiveBlurRadius: CGFloat { 10 - 5 * (1 - visibilityAmount) }

    @State  private var reminderFilters: [Filters] = [.dueToday]
    @State  private var eventFilters: [Filters] = [.happensToday]

    @Namespace private var largeTitle

    @State  private var date: Date
    private let context: SingleDayContext

    init(date: Date) {
        self.date = date
        context = SingleDayContext(
            for: date,
            in: DataContext.shared
        )
    }

    private var reminders: [CalendarItem] {
        context.reminders.filter(Filters.all(of: reminderFilters).filter).compactMap(CalendarItem.init)
    }

    private var events: [CalendarItem] {
        context.events.filter(Filters.any(of: eventFilters).filter).compactMap(CalendarItem.init)
    }

    @State private var disappeared: Bool = false

    private func topBar(with font: Font, height: CGFloat) -> some View {
        TopBar(font: font, height: height) {
            todaysDate
        } trailing: {
            Button("Create a calendar item", systemImage: "plus") {
                presentation.toggleMenu(.new())
            }
            Button("Settings", systemImage: "gear") {
                presentation.toggleMenu(.settings)
            }
            .contextMenu {
                Button("Refresh", systemImage: "arrow.clockwise") {
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
        }
    }

    var body: some View {
        BlurryScrollView(blurHeight: effectiveBlurHeight, blurRadius: effectiveBlurRadius) {
            LazyVStack(spacing: 0) {
                Rectangle()
                    .fill(.clear)
                    .frame(height: topBarHeight)
                    .trackVisibilityPercentage($visibilityAmount)

                LazyVStack(spacing: 16) {
                    OnboardingView()

                    ForEach(reminders) { item in
                        PreviewCalItemView(item: item)
                    }

                    ForEach(events) { item in
                        PreviewCalItemView(item: item)
                    }
                }
                .padding()
            }
            .padding(.bottom, presentation.bottomBarSize?.height)
            .safeAreaPadding(.top, topSafeAreaHeight)
        }
        .overlay(alignment: .top) {
            topBar(
                with: effectiveTopBarHeight == topBarHeight ? .largeTitle : .title3,
                height: effectiveTopBarHeight
            )
            .safeAreaPadding(.top, topSafeAreaHeight)
            .animation(.default, value: visibilityAmount)
        }
    }

    private func formattedToday(day: String, date: String) -> some View {
        HStack(spacing: 0.5) {
            Text(day)
            Text(date)
                .foregroundColor(.red)
        }
        .fontWeight(.bold)
        .fontDesign(.rounded)
        .textCase(.uppercase)
    }

    @ViewBuilder private var todaysDate: some View {
        let dateLiterals = Date.now.literals
        let date = dateLiterals[.date]
        var day: String? {
            dynamicTypeSize > .xLarge
                ? dateLiterals[.medium]
                : dateLiterals[. long]
        }
        if let day, let date {
            formattedToday(day: day, date: date)
        }
    }
}

struct PreviewCalItemView: View {
    let item: CalendarItem

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(item.title)
                    .font(.title3)
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .fill(.clear)
                .stroke(Color.primary.quaternary, lineWidth: 0.5)
        }
    }
}

struct PreviewEventView: View {
    let event: CalendarItem

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(event.title)
                    .font(.title3)
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(GlassStyle(.rect(cornerRadius: 12)))
    }
}

struct PreviewReminderView: View {
    let reminder: CalendarItem

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(reminder.title)
                    .font(.title3)
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(GlassStyle(.rect(cornerRadius: 12)))
    }
}

struct VisibilityPercentageModifier: ViewModifier {
    @Binding var visibilityPercentage: CGFloat
    let coordinateSpace: CoordinateSpace

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            // Initial calculation
                            updateVisibility(geometry)
                        }
                        .onChange(of: geometry.frame(in: coordinateSpace)) { _, _ in
                            // Update on frame changes
                            updateVisibility(geometry)
                        }
                }
            )
    }

    private func updateVisibility(_ geometry: GeometryProxy) {
        // Get the view bounds in the specified coordinate space
        let rect = geometry.frame(in: coordinateSpace)

        // Get the visible portion by checking the intersection with the global bounds
        let globalFrame: CGRect
        switch coordinateSpace {
        case .global:
            // For global space, we need to know the screen bounds
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let screen = windowScene.windows.first?.screen {
                globalFrame = CGRect(x: 0, y: 0, width: screen.bounds.width, height: screen.bounds.height)
            } else {
                globalFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            }
        case .named:
            // For named spaces, we approximate based on the view's current frame
            globalFrame = rect
        default:
            // For local space, the view's own bounds are the reference
            globalFrame = CGRect(origin: .zero, size: rect.size)
        }

        // Calculate intersection of view frame with visible area
        let intersection = rect.intersection(globalFrame)

        // Handle cases where there's no intersection
        if intersection.isNull || rect.width == 0 || rect.height == 0 {
            DispatchQueue.main.async {
                visibilityPercentage = 0.0
            }
            return
        }

        // Calculate percentage of view that's visible
        let visibleArea = intersection.width * intersection.height
        let totalArea = rect.width * rect.height
        let percentage = visibleArea / totalArea

        DispatchQueue.main.async {
            visibilityPercentage = percentage
        }
    }
}

extension View {
    /// Adds a modifier that updates the binding with the percentage of the view that is visible on screen
    /// - Parameters:
    ///   - visibilityPercentage: A binding to update with the visibility percentage (0.0 to 1.0)
    ///   - coordinateSpace: The coordinate space to use for visibility calculations (default: .global)
    /// - Returns: A modified view that updates the binding with its visibility percentage
    func trackVisibilityPercentage(
        _ visibilityPercentage: Binding<CGFloat>,
        in coordinateSpace: CoordinateSpace = .global
    ) -> some View {
        self.modifier(VisibilityPercentageModifier(
            visibilityPercentage: visibilityPercentage,
            coordinateSpace: coordinateSpace
        ))
    }
}
