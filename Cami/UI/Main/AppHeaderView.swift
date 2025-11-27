//
//  AppHeaderView.swift
//  Cami
//
//  Created by Guillaume Coquard on 29/03/25.
//

import AemiSDR
import SwiftUI
import WidgetKit

struct AppHeaderView: View {
    @Environment(AppNavigation.self) private var navigation
    @Environment(AppState.self) private var appState

    @State private var topSafeAreaInset = CGFloat.zero
    @Binding private var viewHeight: CGFloat

    let layoutScrollOffset: CGFloat

    private var displayedDate: Date {
        appState.selectedDate
    }

    init(
        height: Binding<CGFloat>,
        offset: CGFloat
    ) {
        self._viewHeight = height
        self.layoutScrollOffset = offset
    }

    var body: some View {
        TopBar(scrollOffset: layoutScrollOffset) {
            HStack(spacing: 8) {
                ViewThatFits(in: .horizontal) {
                    longDate
                    shortDate
                }
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.25), value: displayedDate)

                if !appState.isViewingToday {
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            appState.navigateToToday()
                        }
                    } label: {
                        Label(String(localized: "button.returnToToday"), systemImage: "arrow.uturn.backward")
                            .labelStyle(.iconOnly)
                            .font(.caption.weight(.semibold))
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .tint(.red)
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.5)
                                .combined(with: .opacity)
                                .combined(with: .offset(x: -10)),
                            removal: .scale(scale: 0.8)
                                .combined(with: .opacity)
                        )
                    )
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: appState.isViewingToday)
        } trailing: {
            Button(String(localized: "button.createCalendarItem"), systemImage: "plus") {
                navigation.navigate(to: .createEvent(date: appState.selectedDate))
            }
            .transition(.scale.combined(with: .opacity))

            Button(String(localized: "button.settings"), systemImage: "gear") {
                navigation.navigate(to: .settings)
            }
            .transition(.scale.combined(with: .opacity))
            .contextMenu {
                Button(String(localized: "button.refresh"), systemImage: "arrow.clockwise") {
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
        }
        .track(height: $viewHeight)
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

    @ViewBuilder private var longDate: some View {
        if let day = displayedDate.literals[.long], let dateStr = displayedDate.literals[.date] {
            formattedToday(day: day, date: dateStr)
        }
    }

    @ViewBuilder private var shortDate: some View {
        if let day = displayedDate.literals[.short], let dateStr = displayedDate.literals[.date] {
            formattedToday(day: day, date: dateStr)
        }
    }
}
