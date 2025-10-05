//
//  CamiApp.swift
//  Cami
//
//  Created by Guillaume Coquard on 03/11/23.
//

import SwiftUI

@main
struct CamiApp: App {
    @LazyState private var appState = AppState(date: .now)
    @LazyState private var permissionManager = PermissionManager()

    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(\.appState, appState)
                .environment(appState.navigation)
                .environment(\.data, .shared)
                .environment(\.modal, .shared)
                .environment(\.views, .shared)
                .environment(\.locale, .prefered)
                .onOpenURL(perform: Router.shared.handleURL)
                .refreshWidgets()
                .environment(\.viewKind, .standard)
                .environment(permissionManager)
        }
    }
}
