//
//  AppNavigation+Views.swift
//  Cami
//
//  Created by Guillaume Coquard on 05.10.25.
//

import SwiftUI

extension AppNavigation {
    /// Returns the appropriate view for a given navigation destination
    @ViewBuilder
    func view(for destination: NavigationDestination) -> some View {
        Group {
            switch destination {
                case .main: EmptyView()
                case .onboarding: OnboardingView()
                case .settings: EmptyView()
                @unknown default: EmptyView()
            }
        }
        .environment(self)
    }
}
