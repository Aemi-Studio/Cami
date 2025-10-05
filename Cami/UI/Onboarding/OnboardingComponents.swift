//
// MARK: - Progress Indicator
fileprivate enum OnboardingStep: Int, CaseIterable, Sendable {
    case intro
    case calendar
    case contacts
    case reminders
    case completion

    static func fromPermission(_ permission: PermissionManager.Permission) -> OnboardingStep {
        switch permission {
        case .calendar: .calendar
        case .contacts: .contacts
        case .reminders: .reminders
        }
    }
}

struct OnboardingProgressView: View {
    let current: OnboardingStep

    private var steps: [OnboardingStep] { OnboardingStep.allCases }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(steps, id: \.self) { step in
                Capsule()
                    .fill(color(for: step).gradient)
                    .frame(height: 6)
                    .animation(.easeInOut, value: current)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(progressLabel)
    }

    private func color(for step: OnboardingStep) -> Color {
        if step.rawValue < current.rawValue { return .green }
        if step == current { return .accentColor }
        return .secondary.opacity(0.3)
    }

    private var progressLabel: String {
        let index = current.rawValue + 1
        let total = steps.count
        return String(localized: "onboarding.progress \(index) / \(total)")
    }
}


//  OnboardingComponents.swift
//  Cami
//
//  Created by Assistant on 05/10/25.
//

import SwiftUI

// MARK: - Title / Hero
struct OnboardingTitleView: View {
    var body: some View {
        VStack {
            Text(String(localized: "onboarding.titlePrefix"))
                .font(.title)
            Text("Cami Calendar")
                .font(.largeTitle)
        }
        .fontWeight(.bold)
    }
}

struct OnboardingHeroView: View {
    var body: some View {
        VStack(spacing: 12) {
            OnboardingTitleView()
            Text(String(localized: "onboarding.description"))
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Containers
struct OnboardingCard<Content: View>: View {
    @Environment(\.tint) private var tint
    let backgroundTint: Color?
    @ViewBuilder var content: () -> Content

    init(backgroundTint: Color? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.backgroundTint = backgroundTint
        self.content = content
    }

    var body: some View {
        content()
            .frame(maxWidth: .infinity)
            .padding()
            .background { GlassStyle(.rect(cornerRadius: 8), color: backgroundTint ?? tint) }
    }
}

// MARK: - Actions
struct OnboardingPermissionActionButton: View {
    let action: () -> Void

    var body: some View {
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
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(
                String(localized: "onboarding.callToAction.continue"),
                systemImage: "arrow.forward.square"
            ) {
                action()
            }
            .buttonStyle(.customBorderedButton(foregroundStyle: Color.white, radius: 8, opacity: 1))
            .font(.title3)
            .fontWeight(.medium)
        }
    }
}

struct OnboardingDoneStatusView: View {
    var body: some View {
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
}

struct OnboardingRestrictedSettingsButton: View {
    let action: () -> Void

    var body: some View {
        Button { action() } label: {
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

// MARK: - Preview
#Preview("Onboarding Components") {
    VStack(spacing: 24) {
        OnboardingHeroView()
        OnboardingCard(backgroundTint: .blue) {
            OnboardingPermissionActionButton {}
        }
        OnboardingDoneStatusView()
        OnboardingRestrictedSettingsButton {}
    }
    .padding()
}
