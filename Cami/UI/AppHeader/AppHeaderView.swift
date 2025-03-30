//
//  AppHeaderView.swift
//  Cami
//
//  Created by Guillaume Coquard on 29/03/25.
//

import SwiftUI
import WidgetKit

struct AppHeaderView: View {
    @Environment(\.openModal) private var openModal
    @Environment(\.presentation) private var presentation
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let date: Date

    private var topSafeAreaHeight: CGFloat {
        UIApplication.currentWindow?.safeAreaInsets.top ?? 0
    }

    var body: some View {
        ZStack {
            VariableBlurView(
                maxBlurRadius: presentation.topBlurRadius,
                direction: .blurredTopClearBottom
            )
            .frame(height: presentation.safeScaledTopBarHeight)

            TopBar(height: presentation.scaledTopBarHeight) {
                todaysDate
            } trailing: {
                Button("Create a calendar item", systemImage: "plus") {
                    openModal?(.new())
                }
                Button("Settings", systemImage: "gear") {
                    openModal?(.settings)
                }
                .contextMenu {
                    Button("Refresh", systemImage: "arrow.clockwise") {
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
            }
            .safeAreaPadding(.top, topSafeAreaHeight)
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
        let dateLiterals = date.literals
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
