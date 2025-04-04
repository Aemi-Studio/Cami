//
//  OnboardingView.swift
//  Cami
//
//  Created by Guillaume Coquard on 09/02/24.
//

import SwiftUI
import WidgetKit

struct OnboardingView: View {
    @Environment(\.openModal) private var openModal
    @Environment(\.permissions) private var permissions
    @Environment(\.tint) private var tint

    @AppStorage(SettingsKeys.hasDismissedOnboarding)
    private var hasDismissedOnboarding: Bool = UserDefaults.standard.bool(forKey: SettingsKeys.hasDismissedOnboarding)

    private var authorized: Bool {
        permissions.global == .authorized
    }

    private var restricted: Bool {
        permissions.global == .restricted
    }

    var body: some View {
        VStack {
            if !hasDismissedOnboarding {
                content
                    .frame(maxHeight: hasDismissedOnboarding ? 0 : nil)
                    .transition(
                        .asymmetric(
                            insertion: .push(from: .top),
                            removal: .move(edge: .top)
                        )
                        .combined(with: .opacity)
                    )
            }
        }
        .padding(.top, hasDismissedOnboarding ? 0 : 16)
        .animation(.default, value: hasDismissedOnboarding)
    }

    @ViewBuilder var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
        }
        .overlay(alignment: .topTrailing) {
            if authorized {
                Button(
                    String(localized: "onboarding.dismissButton.label"),
                    systemImage: "xmark"
                ) {
                    hasDismissedOnboarding = true
                }
                .labelStyle(.iconOnly)
                .font(.title3)
                .foregroundStyle(Color.primary.tertiary)
                .fontWeight(.medium)
                .padding()
            }
        }
    }

    var title: some View {
        VStack {
            Text(String(localized: "onboarding.titlePrefix"))
                .font(.title)
            Text("Cami Calendar")
                .font(.largeTitle)
        }
        .fontWeight(.bold)
    }

    @ViewBuilder private var hero: some View {
        title
        Text(String(localized: "onboarding.description"))
    }

    var header: some View {
        VStack(alignment: .center, spacing: 32) {
            hero
            if !authorized {
                if restricted {
                    onboardingRestrictedButton
                } else {
                    onboardingCallToActionButton
                }
            } else {
                onboardingDoneButton
            }
        }
        .multilineTextAlignment(.center)
        .padding(.top, 32)
        .frame(maxWidth: .infinity)
        .padding()
        .background { GlassStyle(.rect(cornerRadius: 16)) }
        .contextMenu {
            WidgetsRefreshButton()
        }
    }

    private var onboardingCallToActionButton: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(String(localized: "onboarding.action.title"))
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.primary)

                Text(String(localized: "onboarding.action.description"))
                    .font(.body)
                    .fontWeight(.regular)
                    .foregroundStyle(Color.primary.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .multilineTextAlignment(.leading)
            .lineLimit(nil)

            Button(
                String(localized: "onboarding.callToAction.continue"),
                systemImage: "arrow.forward.square"
            ) {
                openModal?(.permissions)
            }
            .buttonStyle(.customBorderedButton(foregroundStyle: Color.white, radius: 8, opacity: 1))
            .font(.title3)
            .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background { GlassStyle(.rect(cornerRadius: 8), color: tint) }
    }

    private var onboardingDoneButton: some View {
        VStack(alignment: .center, spacing: 6) {
            Text(String(localized: "onboarding.ok"))
                .font(.title3)
                .fontWeight(.semibold)
            Text(String(localized: "onboarding.ok.description"))
                .foregroundStyle(Color.secondary)
        }
        .fontDesign(.rounded)
        .multilineTextAlignment(.center)
        .padding(12)
        .frame(maxWidth: .infinity)
        .background { GlassStyle(.rect(cornerRadius: 8), color: .green, intensity: 0.25) }
    }

    private var onboardingRestrictedButton: some View {
        Button {
            AppContext.open(.settings)
        } label: {
            CustomBorderedButton(foregroundStyle: Color.white, radius: 8, opacity: 1) {
                Text(String(localized: "onboarding.restricted.callToAction.title"))
            } icon: {
                Image(systemName: "gear")
            } description: {
                Text(String(localized: "onboarding.restricted.callToAction.description"))
                    .font(.subheadline)
            }
            .font(.title3)
            .fontWeight(.medium)
        }
        .tinted(.red)
    }
}
