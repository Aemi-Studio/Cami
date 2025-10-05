//
//  OnboardingView.swift
//  Cami
//
//  Created by Guillaume Coquard on 09/02/24.
//

import SwiftUI
import WidgetKit

/// OnboardingView
/// Refactored to use new navigation strategy and extracted reusable components.
/// Presentation decision (sheet vs inline) is handled by NavigationDestination configuration (.sheet).
struct OnboardingView: View {
    @Environment(AppNavigation.self) private var navigation
    @Environment(PermissionManager.self) private var permissionManager
    @Environment(\.tint) private var tint

    @AppStorage(SettingsKeys.hasDismissedOnboarding)
    private var hasDismissedOnboarding: Bool = UserDefaults.standard.bool(forKey: SettingsKeys.hasDismissedOnboarding)

    private var authorized: Bool { permissionManager.areAllPermissionsGranted() }
    private var restricted: Bool { permissionManager.isSomePermissionRestricted() }

    private var maxHeight: CGFloat? { hasDismissedOnboarding ? 0 : nil }

    var body: some View {
        VStack { content }
            .animation(.default, value: hasDismissedOnboarding)
    }

    @ViewBuilder private var content: some View {
        if !hasDismissedOnboarding {
            VStack(alignment: .leading, spacing: 16) { header }
                .overlay(alignment: .topTrailing) { dismissButton }
                .padding(.bottom, 26)
                .frame(maxHeight: maxHeight)
                .transition(
                    .asymmetric(
                        insertion: .push(from: .top),
                        removal: .move(edge: .top)
                    ).combined(with: .opacity)
                )
        }
    }

    @ViewBuilder private var dismissButton: some View {
        if authorized {
            Button(String(localized: "onboarding.dismissButton.label"), systemImage: "xmark") {
                withAnimation { hasDismissedOnboarding = true }
            }
            .labelStyle(.iconOnly)
            .font(.title3)
            .foregroundStyle(Color.primary.tertiary)
            .fontWeight(.medium)
            .padding()
            .contentShape(.rect)
        }
    }

    private var header: some View {
        VStack(alignment: .center, spacing: 32) {
            OnboardingHeroView()
            if !authorized { permissionSection } else { OnboardingDoneStatusView() }
        }
        .multilineTextAlignment(.center)
        .padding(.top, 32)
        .frame(maxWidth: .infinity)
        .padding()
        .background { GlassStyle(.rect(cornerRadius: 16)) }
        .contextMenu { WidgetsRefreshButton() }
    }

    @ViewBuilder private var permissionSection: some View {
        if restricted {
            OnboardingRestrictedSettingsButton { AppContext.open(.settings) }
        } else {
            OnboardingCard(backgroundTint: tint) {
                OnboardingPermissionActionButton {
                    navigation.navigate(to: .permissions)
                }
            }
        }
    }
}

