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
    @Environment(\.openModal) private var openModal
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

                if !appState.isViewingToday {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
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
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.2), value: appState.isViewingToday)
        } trailing: {
            Button(String(localized: "button.createCalendarItem"), systemImage: "plus") {
                openModal?(.new())
            }
            Button(String(localized: "button.settings"), systemImage: "gear") {
                navigation.navigate(to: .settings)
            }
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
