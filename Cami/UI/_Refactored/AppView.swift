//
//  AppView.swift
//  Cami
//
//  Created by Guillaume Coquard on 03/11/23.
//

import AemiSDR
import EventKit
import OSLog
import SwiftUI
import WidgetKit

struct AppView: View {
    @Environment(\.appState) private var appState
    @Environment(AppNavigation.self) private var navigation
    
    @State private var state = AppViewState()
    @State private var topSafeAreaInset = CGFloat.zero
    
    @AppStorage(SettingsKeys.hasDismissedOnboarding)
    private var hasDismissedOnboarding: Bool = UserDefaults.standard.bool(forKey: SettingsKeys.hasDismissedOnboarding)
    
    var body: some View {
        @Bindable var navigation = navigation
        
        NavigationStack(path: $navigation.path) {
            ZStack(alignment: .top) {
                content
                blur
                header
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar(.hidden, for: .navigationBar)
            .track(safeAreaInsets: $topSafeAreaInset, edge: .top)
            .navigationDestination(for: NavigationDestination.self) { destination in
                navigation.view(for: destination)
            }
        }
        .sheet(item: $navigation.sheetDestination) { destination in
            SheetContent(for: destination)
        }
        .fullScreenCover(item: $navigation.fullScreenCoverDestination) { destination in
            FullScreenCoverContent(for: destination)
        }
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

// MARK: - Modal Content Wrappers

private struct SheetContent: View {
    let destination: NavigationDestination
    @Environment(AppNavigation.self) private var navigation
    
    init(for destination: NavigationDestination) {
        self.destination = destination
    }
    
    var body: some View {
        NavigationStack(path: navigation.modalPath(for: destination)) {
            navigation.view(for: destination)
                .navigationDestination(for: NavigationDestination.self) { nestedDestination in
                    navigation.view(for: nestedDestination)
                }
        }
    }
}

private struct FullScreenCoverContent: View {
    let destination: NavigationDestination
    @Environment(AppNavigation.self) private var navigation
    
    init(for destination: NavigationDestination) {
        self.destination = destination
    }
    
    var body: some View {
        NavigationStack(path: navigation.modalPath(for: destination)) {
            navigation.view(for: destination)
                .navigationDestination(for: NavigationDestination.self) { nestedDestination in
                    navigation.view(for: nestedDestination)
                }
        }
    }
}

@Observable
@MainActor
final class AppViewState {
    var topBarHeight = CGFloat.zero
    var scrollViewOffset = CGFloat.zero
}
