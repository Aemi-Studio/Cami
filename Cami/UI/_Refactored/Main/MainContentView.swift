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
    @Environment(\.appState) private var appState
    @Environment(AppNavigation.self) private var navigation

    @State private var state = MainContentViewState()
    @State private var topSafeAreaInset = CGFloat.zero

    @AppStorage(SettingsKeys.hasDismissedOnboarding)
    private var hasDismissedOnboarding: Bool = UserDefaults.standard.bool(forKey: SettingsKeys.hasDismissedOnboarding)

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
            offset: state.scrollViewOffset
        )
    }

    private var content: some View {
        appState.map { appState in
            ScrollOffsetReader($state.scrollViewOffset, showsIndicators: false) {
                VStack(spacing: 0) {
                    padded {
                        if !hasDismissedOnboarding {
                            OnboardingView()
                        }
                        SingleDayView(context: appState.dayContext)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, state.topBarHeight)
            }
            .scrollClipDisabled()
            .mask { maskContent }
        }
    }

    private func padded(@ViewBuilder content: () -> some View) -> some View {
        content().padding(.horizontal)
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