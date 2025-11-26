//
//  CamiApp.swift
//  Cami
//
//  Created by Guillaume Coquard on 03/11/23.
//

import SwiftUI

@main
struct CamiApp: App {
    @LazyState private var appState = AppState()
    @LazyState private var permissionManager = PermissionManager()
    @State private var dayStore = DayStore.shared

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(appState)
                .environment(appState.navigation)
                .environment(dayStore)
                .environment(\.data, .shared)
                .environment(\.locale, .prefered)
                .withNavigationHandling()
                .refreshWidgets()
                .environment(\.viewKind, .standard)
                .environment(permissionManager)
                .task {
                    await startServices()
                }
        }
    }

    private func startServices() async {
        // Start CalendarStore to observe EventKit and settings changes
        await CalendarStore.shared.startObserving()

        // Start DayStore to observe CalendarStore changes
        await MainActor.run {
            dayStore.startObserving()
        }

        // Start LiveActivity monitoring
        await LiveActivityService.shared.startMonitoring()
    }
}
