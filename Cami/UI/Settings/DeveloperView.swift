//
//  DeveloperView.swift
//  Cami
//
//  Created by Guillaume Coquard on 30/03/25.
//

import SwiftUI

struct DeveloperView: View {
    @Environment(\.permissions) private var permissions
    
    @AppStorage(SettingsKeys.hasDismissedOnboarding)
    private var hasDismissedOnboarding: Bool = UserDefaults.standard.bool(forKey: SettingsKeys.hasDismissedOnboarding)
    
    private var hasDismissedOnboardingBinding: Binding<Bool> {
        Binding {
            hasDismissedOnboarding
        } set: {
            hasDismissedOnboarding = $0
        }
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 16) {
                CustomSection {
                    toggleOnboarding
                    resetPermissionsButton
                }
            }
            .padding(.horizontal)
            .navigationTitle(String(localized: "view.developer.title"))
        }
    }
    
    private var toggleOnboarding: some View {
        BorderedToggle(isOn: hasDismissedOnboardingBinding) {
            Text(String(localized: "settings.developer.hasDismissedOnboarding.title"))
        }
    }
    
    private var resetPermissionsButton: some View {
        Button(
            String(localized: "settings.developer.resetPermissions.title"),
            systemImage: "arrow.counterclockwise"
        ) {
            hasDismissedOnboarding = false
            permissions.reset()
        }
        .buttonStyle(.primaryWithOutline)
    }
    
}
