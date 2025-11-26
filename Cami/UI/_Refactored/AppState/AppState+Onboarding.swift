//
//  AppState+Onboarding.swift
//  Cami
//
//  Created by Guillaume Coquard on 05.10.25.
//

import Foundation

extension AppState {
    /// Whether the user has completed onboarding
    /// Uses legacy storage for synchronous access, syncs with AppSettings
    var hasCompletedOnboarding: Bool {
        storage.hasCompletedInitialOnboarding
    }

    var completedOnboardingSteps: [OnboardingStep] {
        storage.completedOnboardingSteps.compactMap(OnboardingStep.init)
    }

    var onboardingSteps: [OnboardingStep] {
        if !hasCompletedOnboarding {
            OnboardingStep.initialOnboarding
        } else {
            OnboardingStep.allCases.filter {
                !(completedOnboardingSteps.contains($0) || OnboardingStep.initialOnboarding.contains($0))
            }
        }
    }

    func completeOnboarding(steps: [OnboardingStep]) {
        guard !steps.isEmpty else { return }

        validations.forEach { $0(steps) }

        navigation.reset()
    }

    private var validations: [(_ steps: [OnboardingStep]) -> Void] {
        [validateInitialOnboarding]
    }

    private func validateInitialOnboarding(from steps: [OnboardingStep]) {
        if steps == OnboardingStep.initialOnboarding {
            // Update both legacy storage and new AppSettings
            storage.hasCompletedInitialOnboarding = true
            storage.completedOnboardingSteps.formUnion(OnboardingStep.initialOnboarding.map(\.rawValue))

            // Also update AppSettings for future use
            Task {
                await settings.completeOnboarding()
                for step in steps {
                    await settings.completeOnboardingStep(step)
                }
            }
        }
    }
}
