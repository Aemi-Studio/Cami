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
    
    @State private var topSafeAreaInset = CGFloat.zero
    @Binding private var viewHeight: CGFloat
    
    let layoutScrollOffset: CGFloat
    let date = Date.now
    
    init(
        height: Binding<CGFloat>,
        offset: CGFloat
    ) {
        self._viewHeight = height
        self.layoutScrollOffset = offset
    }

    var body: some View {
        TopBar(scrollOffset: layoutScrollOffset) {
            ViewThatFits(in: .horizontal) {
                longDate
                shortDate
            }
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
        if let day = date.literals[.long], let date = date.literals[.date] {
            formattedToday(day: day, date: date)
        }
    }
    
    @ViewBuilder private var shortDate: some View {
        if let day = date.literals[.short], let date = date.literals[.date] {
            formattedToday(day: day, date: date)
        }
    }
}
