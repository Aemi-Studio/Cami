//
//  MainContentView.swift
//  Cami
//
//  Created by Guillaume Coquard on 05.10.25.
//

import AemiSDR
import EventKit
import OSLog
import SwiftUI
import WidgetKit

/// The main content view of the application
/// Extracted from AppView to separate navigation concerns from content presentation
struct MainContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(AppNavigation.self) private var navigation

    @State private var state = MainContentViewState()
    @State private var topSafeAreaInset = CGFloat.zero

    var body: some View {
        ZStack(alignment: .top) {
            content
            blur
            header
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .navigationBar)
        .track(safeAreaInsets: $topSafeAreaInset, edge: .top)
    }

    private var header: some View {
        AppHeaderView(
            height: $state.topBarHeight,
            offset: appState.currentScrollOffset
        )
    }

    private var content: some View {
        DayPagerView(topPadding: state.topBarHeight)
            .mask { maskContent }
            .ignoresSafeArea(edges: .bottom)
    }

    private var blur: some View {
        VariableBlurView(maxBlurRadius: 5, type: .linearTopToBottom)
            .frame(height: state.topBarHeight + topSafeAreaInset)
            .ignoresSafeArea(edges: .top)
    }

    private var maskContent: some View {
        VStack(spacing: 0) {
            GradientMask(direction: .up).frame(height: state.topBarHeight + topSafeAreaInset)
            Color.black
        }
        .ignoresSafeArea(edges: .top)
    }
}
