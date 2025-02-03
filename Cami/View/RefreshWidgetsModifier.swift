//
//  RefreshWidgetsModifier.swift
//  Cami
//
//  Created by Guillaume Coquard on 02/02/25.
//

import SwiftUI
import WidgetKit

struct RefreshWidgetsModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.permissions) private var permissions
    @Environment(\.views) private var views

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { _, _ in
                WidgetCenter.shared.reloadAllTimelines()
            }
            .onChange(of: permissions?.global) { _, _ in
                views?.reset()
                WidgetCenter.shared.reloadAllTimelines()
            }
            .onReceive(DataContext.shared.publishEventStoreChanges()) { _ in
                WidgetCenter.shared.reloadAllTimelines()
            }
    }
}

extension View {
    func refreshWidgets() -> some View {
        modifier(RefreshWidgetsModifier())
    }
}
