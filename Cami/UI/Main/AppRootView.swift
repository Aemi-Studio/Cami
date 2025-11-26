//
//  AppRootView.swift
//  Cami
//
//  Created by Guillaume Coquard on 05.10.25.
//

import SwiftUI

/// The root view of the application that provides the navigation blueprint.
/// This view is responsible for:
/// - Setting up the NavigationStack with proper path binding
/// - Handling navigation destinations
/// - Managing modal presentations (sheets and full screen covers)
/// - Providing navigation environment to child views
struct AppRootView: View {
    @Environment(AppNavigation.self) private var navigation

    var body: some View {
        @Bindable var navigation = navigation

        NavigationStack(path: $navigation.path) {
            MainContentView()
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
}

// MARK: - Modal Content Wrappers

/// Wrapper for sheet presentations that provides its own NavigationStack
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

/// Wrapper for full screen cover presentations that provides its own NavigationStack
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

#Preview("Navigation Root") {
    AppRootView()
        .environment(AppNavigation())
}