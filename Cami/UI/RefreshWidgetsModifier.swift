//
//  RefreshWidgetsModifier.swift
//  Cami
//
//  Created by Guillaume Coquard on 02/02/25.
//

import SwiftUI
import WidgetKit

struct RefreshWidgetsModifier: ViewModifier {
    @Environment(PermissionManager.self) private var permissionManager

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.views) private var views
    @Environment(\.data) private var context

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { _, _ in
                WidgetCenter.shared.reloadAllTimelines()
            }
            .onReceive(DataContext.shared.publishEventStoreChanges()) { _ in
                WidgetCenter.shared.reloadAllTimelines()
            }
            .task(reactToPermissionChanges)
    }

    @Sendable private func reactToPermissionChanges() async {
        for await _ in permissionManager.getPermissionUpdates() {
            views?.reset()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

extension View {
    func refreshWidgets() -> some View {
        modifier(RefreshWidgetsModifier())
    }
}
