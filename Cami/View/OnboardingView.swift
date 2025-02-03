//
//  OnboardingView.swift
//  Cami
//
//  Created by Guillaume Coquard on 09/02/24.
//

import SwiftUI
import WidgetKit

struct OnboardingView: View {

    @Environment(\.presentation) private var presentation
    @Environment(\.permissions) private var permissions

    @AppStorage(SettingsKeys.hasDismissedOnboarding)
    private var hasDismissedOnboarding: Bool = false

    private var authorized: Bool {
        permissions?.global == .authorized
    }

    private var restricted: Bool {
        permissions?.global == .restricted
    }

    var body: some View {
        if !hasDismissedOnboarding {
            VStack(alignment: .leading, spacing: 16) {
                header
            }
            .overlay(alignment: .topTrailing) {
                if authorized {
                    Button("Dismiss Onboarding", systemImage: "xmark") {
                        withAnimation {
                            hasDismissedOnboarding = true
                        }
                    }
                    .labelStyle(.iconOnly)
                    .font(.title3)
                    .foregroundStyle(Color.primary.tertiary)
                    .fontWeight(.medium)
                    .padding()
                }
            }
            .padding()
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
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 16))
        .contextMenu {
            WidgetsRefreshButton()
        }
    }

    private var onboardingCallToActionButton: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 3) {
                Text(String(localized: "onboarding.action.title"))
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.tint)

                Text(String(localized: "onboarding.action.description"))
                    .font(.body)
                    .fontWeight(.regular)
                    .foregroundStyle(.tint.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .multilineTextAlignment(.leading)
            .lineLimit(nil)

            Button(
                String(localized: "onboarding.callToAction.continue"),
                systemImage: "arrow.forward.square"
            ) {
                presentation?.areSettingsPresented.toggle()
            }
            .buttonStyle(
                .customBorderedButton(
                    foregroundStyle: Color.white,
                    radius: 8,
                    opacity: 1
                )
            )
            .font(.title3)
            .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial.opacity(0.5))
        .background(.tint.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.tint, lineWidth: 0.5)
                .foregroundStyle(.clear)
        }
    }

    private var onboardingDoneButton: some View {
        CustomBorderedButton(
            String(localized: "onboarding.ok"),
            description: String(localized: "onboarding.ok.description"),
            radius: 8,
            outline: true,
            alignment: .center
        )
        .tint(.green)
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
        .tint(.red)
    }
}
