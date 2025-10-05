//
//  AppState+Onboarding.swift
//  Cami
//
//  Created by Guillaume Coquard on 05.10.25.
//

import Foundation

extension AppState {
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
            storage.hasCompletedInitialOnboarding = true
            storage.completedOnboardingSteps.formUnion(OnboardingStep.initialOnboarding.map(\.rawValue))
        }
    }
}
