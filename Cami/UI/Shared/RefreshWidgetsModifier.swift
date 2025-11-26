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
            // CalendarStore handles calendar state updates via EventKit notifications
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

extension View {
    func refreshWidgets() -> some View {
        modifier(RefreshWidgetsModifier())
    }
}
